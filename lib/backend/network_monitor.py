import threading
import time
from collections import deque
from datetime import datetime

from scapy.all import sniff, IP, TCP, UDP


# Your active Wi-Fi adapter
NETWORK_INTERFACE = (
    r"\Device\NPF_{E6908EFE-68C5-4EA4-ADB7-0761CC803A5C}"
)

# How long traffic remains part of the current activity window
WINDOW_SECONDS = 30


class NetworkMonitor:

    def __init__(self):
        self.running = False
        self.thread = None

        self.lock = threading.Lock()

        # ---------------------------------------------------------
        # LIFETIME STATISTICS
        # ---------------------------------------------------------

        self.total_packets = 0
        self.total_bytes = 0

        # ---------------------------------------------------------
        # ROLLING ACTIVITY WINDOW
        # ---------------------------------------------------------

        # Each entry:
        # (timestamp, packet_size, syn, source_ip,
        #  destination_ip, protocol, port, flow)

        self.activity_window = deque()

        # ---------------------------------------------------------
        # RECENT TRAFFIC FOR TRAFFIC PAGE
        # ---------------------------------------------------------

        self.packet_history = deque(maxlen=100)

    # =========================================================
    # START MONITOR
    # =========================================================

    def start(self):

        if self.running:
            return

        self.running = True

        with self.lock:
            self.activity_window.clear()

        self.thread = threading.Thread(
            target=self._capture_packets,
            daemon=True
        )

        self.thread.start()

        print("Network monitor started successfully.")
        print("Packet capture is now active.")

    # =========================================================
    # STOP MONITOR
    # =========================================================

    def stop(self):

        self.running = False

        print("Stopping network monitor...")

    # =========================================================
    # PACKET CAPTURE
    # =========================================================

    def _capture_packets(self):

        try:

            print(
                "Capturing packets from:",
                NETWORK_INTERFACE
            )

            sniff(
                iface=NETWORK_INTERFACE,
                prn=self._process_packet,
                store=False,
                stop_filter=lambda packet: not self.running
            )

        except Exception as error:

            print(
                "Packet capture error:",
                error
            )

    # =========================================================
    # PROCESS PACKET
    # =========================================================

    def _process_packet(self, packet):

        if not self.running:
            return

        if not packet.haslayer(IP):
            return

        timestamp = time.time()

        source_ip = packet[IP].src
        destination_ip = packet[IP].dst

        protocol = "OTHER"
        port = 0
        syn = 0

        # ---------------------------------------------------------
        # TCP
        # ---------------------------------------------------------

        if packet.haslayer(TCP):

            protocol = "TCP"

            port = int(
                packet[TCP].dport
            )

            flags = int(
                packet[TCP].flags
            )

            # SYN without ACK
            if (
                flags & 0x02
                and not flags & 0x10
            ):
                syn = 1

        # ---------------------------------------------------------
        # UDP
        # ---------------------------------------------------------

        elif packet.haslayer(UDP):

            protocol = "UDP"

            port = int(
                packet[UDP].dport
            )

        # ---------------------------------------------------------
        # PACKET SIZE
        # ---------------------------------------------------------

        packet_size = len(packet)

        flow = (
            source_ip,
            destination_ip,
            protocol,
            port
        )

        # ---------------------------------------------------------
        # UPDATE DATA
        # ---------------------------------------------------------

        with self.lock:

            # Lifetime statistics
            self.total_packets += 1
            self.total_bytes += packet_size

            # Add packet to rolling window
            self.activity_window.append(
                (
                    timestamp,
                    packet_size,
                    syn,
                    source_ip,
                    destination_ip,
                    protocol,
                    port,
                    flow
                )
            )

            # Remove old packets
            self._remove_expired_packets(timestamp)

            # -----------------------------------------------------
            # RECENT TRAFFIC
            # -----------------------------------------------------

            self.packet_history.appendleft(
                {
                    "timestamp":
                        datetime.now().isoformat(),

                    "source_ip":
                        source_ip,

                    "destination_ip":
                        destination_ip,

                    "protocol":
                        protocol,

                    "port":
                        port,

                    "packets":
                        1,

                    "status":
                        self._get_packet_status(
                            protocol,
                            port
                        )
                }
            )

    # =========================================================
    # REMOVE OLD WINDOW DATA
    # =========================================================

    def _remove_expired_packets(self, current_time):

        cutoff = current_time - WINDOW_SECONDS

        while self.activity_window:

            oldest_timestamp = (
                self.activity_window[0][0]
            )

            if oldest_timestamp >= cutoff:
                break

            self.activity_window.popleft()

    # =========================================================
    # BASIC TRAFFIC STATUS
    # =========================================================

    def _get_packet_status(
        self,
        protocol,
        port
    ):

        normal_ports = {
            53,     # DNS
            80,     # HTTP
            123,    # NTP
            443,    # HTTPS
        }

        if port in normal_ports:
            return "normal"

        if port in {
            22,
            23,
            3389
        }:
            return "suspicious"

        return "normal"

    # =========================================================
    # GET CURRENT SNAPSHOT
    # =========================================================

    def get_snapshot(self):

        with self.lock:

            now = time.time()

            # Remove packets older than 30 seconds
            self._remove_expired_packets(now)

            # -----------------------------------------------------
            # CURRENT WINDOW METRICS
            # -----------------------------------------------------

            window_packets = len(
                self.activity_window
            )

            window_bytes = sum(
                item[1]
                for item in self.activity_window
            )

            syn_packets = sum(
                item[2]
                for item in self.activity_window
            )

            unique_ips = set()

            destination_ports = set()

            flows = set()

            for item in self.activity_window:

                (
                    timestamp,
                    packet_size,
                    syn,
                    source_ip,
                    destination_ip,
                    protocol,
                    port,
                    flow
                ) = item

                unique_ips.add(source_ip)
                unique_ips.add(destination_ip)

                if port:
                    destination_ports.add(port)

                flows.add(flow)

            # -----------------------------------------------------
            # PACKETS PER SECOND
            # -----------------------------------------------------

            packets_per_second = (
                window_packets / WINDOW_SECONDS
            )

            # -----------------------------------------------------
            # SNAPSHOT
            # -----------------------------------------------------

            snapshot = {

                "timestamp":
                    datetime.now().isoformat(),

                # Lifetime values
                "packets":
                    self.total_packets,

                "data_mb":
                    round(
                        self.total_bytes /
                        (1024 * 1024),
                        2
                    ),

                # Current activity
                "flows":
                    len(flows),

                "unique_ips":
                    len(unique_ips),

                "packets_per_second":
                    round(
                        packets_per_second,
                        2
                    ),

                "window_packets":
                    window_packets,

                "window_bytes":
                    window_bytes,

                "syn_packets":
                    syn_packets,

                "destination_ports":
                    len(destination_ports),

                # Traffic page
                "recent_traffic":
                    list(
                        self.packet_history
                    )
            }

            return snapshot


monitor = NetworkMonitor()
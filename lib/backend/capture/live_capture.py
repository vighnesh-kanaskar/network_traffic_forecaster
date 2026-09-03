from scapy.all import sniff


def capture_packets(
    interface=None,
    packet_count=50
):
    packets = sniff(
        iface=interface,
        count=packet_count
    )

    return packets
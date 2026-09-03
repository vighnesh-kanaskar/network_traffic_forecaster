from scapy.all import IP, TCP, UDP


def analyze_packet(packet):
    result = {
        "source_ip": None,
        "destination_ip": None,
        "protocol": "OTHER",
        "source_port": None,
        "destination_port": None,
        "packet_size": len(packet),
    }

    if IP in packet:
        result["source_ip"] = packet[IP].src
        result["destination_ip"] = packet[IP].dst

    if TCP in packet:
        result["protocol"] = "TCP"
        result["source_port"] = packet[TCP].sport
        result["destination_port"] = packet[TCP].dport

    elif UDP in packet:
        result["protocol"] = "UDP"
        result["source_port"] = packet[UDP].sport
        result["destination_port"] = packet[UDP].dport

    return result
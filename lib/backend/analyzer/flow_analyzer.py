from collections import defaultdict


def build_flows(packets):
    flows = defaultdict(
        lambda: {
            "packets": 0,
            "bytes": 0
        }
    )

    for packet in packets:
        key = (
            packet.get("source_ip"),
            packet.get("destination_ip"),
            packet.get("protocol"),
            packet.get("destination_port")
        )

        flows[key]["packets"] += 1
        flows[key]["bytes"] += packet.get(
            "packet_size",
            0
        )

    return dict(flows)
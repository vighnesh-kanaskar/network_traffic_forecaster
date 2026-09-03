def calculate_risk(snapshot):

    pps = snapshot["packets_per_second"]
    syn = snapshot["syn_packets"]
    unique_ips = snapshot["unique_ips"]
    ports = snapshot["destination_ports"]

    risk = 5

    # Packet rate
    if pps > 100:
        risk += 10

    if pps > 500:
        risk += 15

    if pps > 1000:
        risk += 15

    # SYN activity
    if syn > 20:
        risk += 10

    if syn > 100:
        risk += 15

    if syn > 500:
        risk += 15

    # Destination diversity
    if ports > 10:
        risk += 10

    if ports > 30:
        risk += 10

    # IP diversity
    if unique_ips > 20:
        risk += 5

    if unique_ips > 50:
        risk += 10

    return min(risk, 100)


def determine_state(snapshot, risk):

    syn = snapshot["syn_packets"]
    ports = snapshot["destination_ports"]
    unique_ips = snapshot["unique_ips"]

    if risk < 25:
        return "Normal"

    if ports >= 30 or unique_ips >= 50:
        return "Scanning"

    if syn >= 100:
        return "Reconnaissance"

    if risk >= 70:
        return "Initial Access"

    return "Suspicious Activity"
def calculate_risk(
    packets_per_second: float,
    suspicious_flows: int,
    unique_ports: int
):
    score = 0

    # Traffic volume
    if packets_per_second > 100:
        score += 25
    elif packets_per_second > 50:
        score += 15

    # Suspicious flows
    if suspicious_flows >= 5:
        score += 40
    elif suspicious_flows >= 2:
        score += 25
    elif suspicious_flows >= 1:
        score += 10

    # Port diversity
    if unique_ports > 20:
        score += 30
    elif unique_ports > 10:
        score += 20
    elif unique_ports > 5:
        score += 10

    return min(score, 100)


def get_risk_state(risk: int):
    if risk >= 70:
        return "High Risk"

    if risk >= 40:
        return "Medium Risk"

    return "Low Risk"
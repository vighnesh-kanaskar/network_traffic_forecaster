from services.network_service import get_current_snapshot
from services.risk_service import calculate_risk, determine_state


def get_forecast():

    snapshot = get_current_snapshot()

    risk = calculate_risk(snapshot)

    current_state = determine_state(
        snapshot,
        risk
    )

    syn = snapshot["syn_packets"]
    ports = snapshot["destination_ports"]
    unique_ips = snapshot["unique_ips"]

    evidence = []

    if syn > 20:
        evidence.append({
            "feature": "SYN packet activity",
            "change": "elevated"
        })

    if ports > 10:
        evidence.append({
            "feature": "Destination port diversity",
            "change": "elevated"
        })

    if unique_ips > 20:
        evidence.append({
            "feature": "Unique IP diversity",
            "change": "elevated"
        })

    # Determine probable next state
    if current_state == "Normal":
        predicted_state = "Scanning"

    elif current_state == "Scanning":
        predicted_state = "Reconnaissance"

    elif current_state == "Reconnaissance":
        predicted_state = "Initial Access"

    elif current_state == "Suspicious Activity":
        predicted_state = "Reconnaissance"

    else:
        predicted_state = "Initial Access"

    # Confidence is based on strength of indicators
    confidence = min(
        50 + (risk // 2),
        95
    )

    return {
        "current_state": current_state,
        "predicted_state": predicted_state,
        "confidence": confidence,
        "risk": risk,
        "forecast_window": "5-10 minutes",
        "evidence": evidence
    }
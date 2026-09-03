from datetime import datetime

from services.network_service import get_current_snapshot
from services.risk_service import calculate_risk


_last_alert_times = {}


def _can_create_alert(key, cooldown_seconds=30):

    now = datetime.now().timestamp()

    last_time = _last_alert_times.get(key, 0)

    if now - last_time >= cooldown_seconds:
        _last_alert_times[key] = now
        return True

    return False


def get_alerts():

    snapshot = get_current_snapshot()

    risk = calculate_risk(snapshot)

    alerts = []

    if risk >= 70 and _can_create_alert("high_risk"):

        alerts.append({
            "id": int(datetime.now().timestamp()),
            "severity": "high",
            "title": "High Network Risk",
            "description": (
                f"Network risk reached {risk}% "
                "based on observed traffic behaviour."
            ),
            "timestamp": datetime.now().isoformat()
        })

    if snapshot["syn_packets"] >= 100:

        if _can_create_alert("syn_activity"):

            alerts.append({
                "id": int(datetime.now().timestamp()),
                "severity": "high",
                "title": "Abnormal SYN Activity",
                "description": (
                    "A high number of SYN packets "
                    "was observed."
                ),
                "timestamp": datetime.now().isoformat()
            })

    if snapshot["destination_ports"] >= 30:

        if _can_create_alert("port_scan"):

            alerts.append({
                "id": int(datetime.now().timestamp()),
                "severity": "medium",
                "title": "High Port Diversity",
                "description": (
                    "Traffic is reaching an unusually "
                    "large number of destination ports."
                ),
                "timestamp": datetime.now().isoformat()
            })

    return alerts
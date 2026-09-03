from fastapi import APIRouter

from services.network_service import get_current_snapshot
from services.risk_service import calculate_risk, determine_state


router = APIRouter()


@router.get("/dashboard")
def dashboard():

    snapshot = get_current_snapshot()

    risk = calculate_risk(snapshot)

    current_state = determine_state(
        snapshot,
        risk
    )

    return {
        "risk": risk,
        "confidence": min(50 + risk // 2, 95),
        "current_state": current_state,
        "predicted_state": (
            "Initial Access"
            if risk >= 60
            else "Scanning"
        ),
        "packets": snapshot["packets"],
        "flows": snapshot["flows"],
        "unique_ips": snapshot["unique_ips"],
        "packets_per_second": snapshot[
            "packets_per_second"
        ],
        "data_mb": snapshot["data_mb"]
    }
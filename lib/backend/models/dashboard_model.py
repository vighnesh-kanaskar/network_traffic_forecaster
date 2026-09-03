from pydantic import BaseModel


class DashboardResponse(BaseModel):
    data_mb: float
    packets: int
    packets_per_second: float
    flows: int
    unique_ips: int

    risk: int
    confidence: int

    current_state: str
    predicted_state: str
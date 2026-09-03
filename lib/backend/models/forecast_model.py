from pydantic import BaseModel


class ForecastEvidence(BaseModel):
    feature: str
    change: str


class ForecastResponse(BaseModel):
    current_state: str
    predicted_state: str
    confidence: int
    risk: int
    forecast_window: str
    evidence: list[ForecastEvidence]
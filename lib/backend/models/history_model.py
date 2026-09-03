from pydantic import BaseModel
from datetime import datetime


class HistoryResponse(BaseModel):
    timestamp: datetime
    current_state: str
    predicted_state: str
    risk: int
    confidence: int
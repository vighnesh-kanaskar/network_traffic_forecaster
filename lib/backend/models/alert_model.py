from pydantic import BaseModel


class AlertResponse(BaseModel):
    id: int
    timestamp: str
    title: str
    description: str
    severity: str
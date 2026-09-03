from pydantic import BaseModel


class TrafficRecord(BaseModel):
    timestamp: str
    source_ip: str
    destination_ip: str
    protocol: str
    port: int
    packets: int
    bytes: int
    status: str
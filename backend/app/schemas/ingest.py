from datetime import datetime
from pydantic import BaseModel

class ShipmentEventCreate(BaseModel):
    shipment_id: int
    event_type: str
    location: str | None = None
    description: str | None = None
    event_time: datetime | None = None

class IngestResponse(BaseModel):
    message: str
    shipment_id: int
    event_id: int
    updated_status: str

from pydantic import BaseModel, Field


class ShipmentCreate(BaseModel):
    shipmentId: str = Field(..., min_length=1)
    origin: str = Field(..., min_length=1)
    destination: str = Field(..., min_length=1)
    eta: str = Field(..., min_length=1)
    risk: str = "Medium"
    status: str = "In Transit"


class ShipmentStatusUpdate(BaseModel):
    status: str = Field(..., min_length=1)


class ShipmentWriteResponse(BaseModel):
    success: bool
    message: str
    shipment: dict
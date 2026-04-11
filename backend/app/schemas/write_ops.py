from pydantic import BaseModel, Field


class EventCreateRequest(BaseModel):
    shipmentId: str = Field(..., min_length=1)
    title: str = Field(..., min_length=1)
    description: str = Field(..., min_length=1)


class DecisionCreateRequest(BaseModel):
    shipmentId: str = Field(..., min_length=1)
    author: str = Field(..., min_length=1)
    note: str = Field(..., min_length=1)


class SimpleWriteResponse(BaseModel):
    success: bool
    message: str
    id: str | None = None
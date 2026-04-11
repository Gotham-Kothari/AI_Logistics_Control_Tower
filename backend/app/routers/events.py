from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.repositories.event_repo import EventRepository
from app.repositories.shipment_repo import ShipmentRepository
from app.schemas.write_ops import EventCreateRequest, SimpleWriteResponse
from app.services.exception_engine import ExceptionEngineService
from app.services.risk_service import RiskService
from app.services.serializers import FlutterSerializer
from app.services.state_tracker import StateTrackerService
from app.schemas.write_ops import EventCreateRequest, SimpleWriteResponse

router = APIRouter(prefix="/events", tags=["Events"])


@router.get("")
def list_events(db: Session = Depends(get_db)) -> list[dict]:
    repo = EventRepository(db)
    return [FlutterSerializer.event(item) for item in repo.list_events()]


@router.post("", response_model=SimpleWriteResponse, status_code=201)
def create_event(payload: EventCreateRequest, db: Session = Depends(get_db)):
    shipment_repo = ShipmentRepository(db)
    event_repo = EventRepository(db)

    shipment = shipment_repo.get_by_ref(payload.shipmentId)
    if shipment is None:
        raise HTTPException(
            status_code=404,
            detail=f"Shipment {payload.shipmentId} not found",
        )

    normalized_title = payload.title.strip().lower()

    if "customs" in normalized_title:
        event_type = "CUSTOMS_DELAY"
    elif "risk" in normalized_title:
        event_type = "AT_RISK"
    elif "delay" in normalized_title:
        event_type = "DELAYED"
    elif "deliver" in normalized_title:
        event_type = "DELIVERED"
    else:
        event_type = "UPDATE"

    event = event_repo.create_event(
        shipment_id=shipment.id,
        event_type=event_type,
        title=payload.title.strip(),
        description=payload.description.strip(),
    )

    state_tracker = StateTrackerService(db)
    exception_engine = ExceptionEngineService(db)
    risk_service = RiskService(db)

    shipment = state_tracker.apply_event(shipment, event)
    exception_engine.evaluate(shipment, event)
    risk_service.refresh_shipment_risk(shipment.id)

    return {
        "success": True,
        "message": "Event created successfully",
        "id": f"EVT{event.id:03d}",
    }
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.repositories.shipment_repo import ShipmentRepository
from app.schemas.shipment import ShipmentCreate, ShipmentStatusUpdate, ShipmentWriteResponse
from app.services.exception_engine import ExceptionEngineService
from app.services.risk_service import RiskService
from app.services.serializers import FlutterSerializer
from app.services.state_tracker import StateTrackerService

router = APIRouter(prefix="/shipments", tags=["Shipments"])


@router.get("")
def list_shipments(db: Session = Depends(get_db)) -> list[dict]:
    repo = ShipmentRepository(db)
    return [FlutterSerializer.shipment(item) for item in repo.list_shipments()]


@router.get("/{shipment_ref}")
def get_shipment(shipment_ref: str, db: Session = Depends(get_db)) -> dict:
    repo = ShipmentRepository(db)
    shipment = repo.get_by_ref(shipment_ref)

    if shipment is None:
        raise HTTPException(
            status_code=404,
            detail=f"Shipment {shipment_ref} not found",
        )

    return FlutterSerializer.shipment(shipment)


@router.post("", response_model=ShipmentWriteResponse, status_code=201)
def create_shipment(payload: ShipmentCreate, db: Session = Depends(get_db)):
    repo = ShipmentRepository(db)

    existing = repo.get_by_ref(payload.shipmentId)
    if existing:
        raise HTTPException(
            status_code=409,
            detail=f"Shipment {payload.shipmentId} already exists",
        )

    risk_score = 0.35
    if payload.risk.lower() == "high":
        risk_score = 0.7
    elif payload.risk.lower() == "low":
        risk_score = 0.1

    shipment = repo.create_shipment(
        shipment_ref=payload.shipmentId,
        origin=payload.origin,
        destination=payload.destination,
        eta_text=payload.eta,
        status=payload.status,
        risk_score=risk_score,
    )

    return {
        "success": True,
        "message": "Shipment created successfully",
        "shipment": FlutterSerializer.shipment(shipment),
    }


@router.patch("/{shipment_ref}", response_model=ShipmentWriteResponse)
def update_shipment_status(
    shipment_ref: str,
    payload: ShipmentStatusUpdate,
    db: Session = Depends(get_db),
):
    repo = ShipmentRepository(db)
    shipment = repo.get_by_ref(shipment_ref)

    if shipment is None:
        raise HTTPException(
            status_code=404,
            detail=f"Shipment {shipment_ref} not found",
        )

    state_tracker = StateTrackerService(db)
    exception_engine = ExceptionEngineService(db)
    risk_service = RiskService(db)

    shipment = state_tracker.apply_manual_status_update(shipment, payload.status)
    exception_engine.evaluate(shipment)
    risk_service.refresh_shipment_risk(shipment.id)

    shipment = repo.get_by_ref(shipment_ref)

    return {
        "success": True,
        "message": "Shipment status updated successfully",
        "shipment": FlutterSerializer.shipment(shipment),
    }
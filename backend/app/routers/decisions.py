from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.repositories.action_log_repo import ActionLogRepository
from app.repositories.shipment_repo import ShipmentRepository
from app.schemas.write_ops import DecisionCreateRequest, SimpleWriteResponse
from app.services.serializers import FlutterSerializer

router = APIRouter(prefix="/decisions", tags=["Decisions"])


@router.get("")
def list_decisions(db: Session = Depends(get_db)) -> list[dict]:
    repo = ActionLogRepository(db)
    return [FlutterSerializer.action_log(item) for item in repo.list_logs()]


@router.post("", response_model=SimpleWriteResponse, status_code=201)
def create_decision(payload: DecisionCreateRequest, db: Session = Depends(get_db)):
    shipment_repo = ShipmentRepository(db)
    log_repo = ActionLogRepository(db)

    shipment = shipment_repo.get_by_ref(payload.shipmentId)
    if shipment is None:
        raise HTTPException(
            status_code=404,
            detail=f"Shipment {payload.shipmentId} not found",
        )

    log = log_repo.create_log(
        shipment_id=shipment.id,
        actor=payload.author.strip(),
        note=payload.note.strip(),
        action_type="NOTE",
    )

    return {
        "success": True,
        "message": "Decision log created successfully",
        "id": f"NOTE{log.id:03d}",
    }
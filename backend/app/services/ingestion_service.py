from datetime import datetime
from sqlalchemy.orm import Session

from app.repositories.shipment_repo import ShipmentRepository
from app.repositories.event_repo import EventRepository
from app.services.state_tracker import StateTrackerService
from app.services.exception_engine import ExceptionEngineService
from app.services.risk_service import RiskService


class IngestionService:
    def __init__(self, db: Session):
        self.db = db
        self.shipment_repo = ShipmentRepository(db)
        self.event_repo = EventRepository(db)
        self.state_tracker = StateTrackerService(db)
        self.exception_engine = ExceptionEngineService(db)
        self.risk_service = RiskService(db)

    def ingest_event(
        self,
        shipment_id: int,
        event_type: str,
        location: str | None = None,
        description: str | None = None,
        event_time: datetime | None = None,
    ) -> dict:
        shipment = self.shipment_repo.get_by_id(shipment_id)
        if not shipment:
            raise ValueError(f"Shipment {shipment_id} not found")

        event = self.event_repo.create_event(
            shipment_id=shipment_id,
            event_type=event_type,
            location=location,
            description=description,
            event_time=event_time or datetime.utcnow(),
        )

        updated_shipment = self.state_tracker.apply_event(shipment, event)
        self.exception_engine.evaluate(updated_shipment, event)
        self.risk_service.refresh_shipment_risk(updated_shipment.id)

        return {
            "message": "Event ingested successfully",
            "shipment_id": shipment_id,
            "event_id": event.id,
            "updated_status": updated_shipment.status,
        }
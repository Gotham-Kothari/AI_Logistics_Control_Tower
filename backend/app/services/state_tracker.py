from sqlalchemy.orm import Session

from app.models.shipment import Shipment
from app.models.shipment_event import ShipmentEvent
from app.repositories.shipment_repo import ShipmentRepository


class StateTrackerService:
    def __init__(self, db: Session):
        self.db = db
        self.shipment_repo = ShipmentRepository(db)

    def apply_event(self, shipment: Shipment, event: ShipmentEvent) -> Shipment:
        title = (event.title or "").strip().lower()
        event_type = (event.event_type or "").upper()

        if event.location:
            shipment.current_location = event.location

        normalized = title or event_type.lower()

        if "customs" in normalized:
            shipment.status = "Customs Delay"
            shipment.delay_hours = max(shipment.delay_hours, 24)
        elif "risk" in normalized:
            shipment.status = "At Risk"
            shipment.delay_hours = max(shipment.delay_hours, 12)
        elif "delay" in normalized:
            shipment.status = "Delayed"
            shipment.delay_hours = max(shipment.delay_hours, 12)
        elif "deliver" in normalized:
            shipment.status = "Delivered"
            shipment.delay_hours = 0
        elif "transit" in normalized or "depart" in normalized:
            shipment.status = "In Transit"
        else:
            shipment.status = shipment.status or "In Transit"

        return self.shipment_repo.update_shipment(shipment)

    def apply_manual_status_update(self, shipment: Shipment, new_status: str) -> Shipment:
        normalized = new_status.strip().lower()

        shipment.status = new_status

        if normalized in {"delayed", "at risk", "customs delay"}:
            shipment.delay_hours = max(shipment.delay_hours, 12)
        elif normalized == "delivered":
            shipment.delay_hours = 0

        return self.shipment_repo.update_shipment(shipment)
from datetime import datetime

from sqlalchemy.orm import Session

from app.models.shipment_event import ShipmentEvent


class EventRepository:
    def __init__(self, db: Session):
        self.db = db

    def create_event(
        self,
        shipment_id: int,
        event_type: str,
        title: str,
        description: str | None = None,
        location: str | None = None,
        event_time: datetime | None = None,
    ) -> ShipmentEvent:
        event = ShipmentEvent(
            shipment_id=shipment_id,
            event_type=event_type,
            title=title,
            description=description,
            location=location,
            event_time=event_time or datetime.utcnow(),
        )
        self.db.add(event)
        self.db.commit()
        self.db.refresh(event)
        return event

    def list_events(self) -> list[ShipmentEvent]:
        return (
            self.db.query(ShipmentEvent)
            .order_by(ShipmentEvent.event_time.desc(), ShipmentEvent.id.desc())
            .all()
        )

    def list_events_for_shipment(self, shipment_id: int) -> list[ShipmentEvent]:
        return (
            self.db.query(ShipmentEvent)
            .filter(ShipmentEvent.shipment_id == shipment_id)
            .order_by(ShipmentEvent.event_time.desc(), ShipmentEvent.id.desc())
            .all()
        )

    def get_latest_event(self, shipment_id: int) -> ShipmentEvent | None:
        return (
            self.db.query(ShipmentEvent)
            .filter(ShipmentEvent.shipment_id == shipment_id)
            .order_by(ShipmentEvent.event_time.desc(), ShipmentEvent.id.desc())
            .first()
        )
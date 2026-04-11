from sqlalchemy.orm import Session

from app.models.exception_case import ExceptionCase
from app.models.shipment import Shipment


class ShipmentRepository:
    def __init__(self, db: Session):
        self.db = db

    def list_shipments(self) -> list[Shipment]:
        return (
            self.db.query(Shipment)
            .order_by(Shipment.created_at.desc(), Shipment.id.desc())
            .all()
        )

    def get_by_ref(self, shipment_ref: str) -> Shipment | None:
        return (
            self.db.query(Shipment)
            .filter(Shipment.shipment_ref == shipment_ref)
            .first()
        )

    def get_by_id(self, shipment_id: int) -> Shipment | None:
        return self.db.query(Shipment).filter(Shipment.id == shipment_id).first()

    def create_shipment(
        self,
        shipment_ref: str,
        origin: str,
        destination: str,
        carrier: str = "ControlHub Carrier",
        eta_text: str | None = None,
        status: str = "In Transit",
        risk_score: float = 0.35,
    ) -> Shipment:
        shipment = Shipment(
            shipment_ref=shipment_ref,
            origin=origin,
            destination=destination,
            carrier=carrier,
            eta_text=eta_text,
            status=status,
            risk_score=risk_score,
        )
        self.db.add(shipment)
        self.db.commit()
        self.db.refresh(shipment)
        return shipment

    def update_shipment(self, shipment: Shipment) -> Shipment:
        self.db.add(shipment)
        self.db.commit()
        self.db.refresh(shipment)
        return shipment

    def get_shipment_context(self, shipment_ref: str) -> dict:
        shipment = self.get_by_ref(shipment_ref)
        if not shipment:
            raise ValueError(f"Shipment {shipment_ref} not found")

        active_exception_count = (
            self.db.query(ExceptionCase)
            .filter(
                ExceptionCase.shipment_id == shipment.id,
                ExceptionCase.is_active.is_(True),
            )
            .count()
        )

        latest_event = shipment.events[0] if shipment.events else None

        return {
            "shipment_id": shipment.id,
            "shipment_ref": shipment.shipment_ref,
            "origin": shipment.origin,
            "destination": shipment.destination,
            "carrier": shipment.carrier,
            "status": shipment.status,
            "delay_hours": shipment.delay_hours,
            "exception_count": active_exception_count,
            "last_event_type": latest_event.event_type if latest_event else None,
            "current_location": shipment.current_location,
            "eta_confidence": (
                "low"
                if shipment.delay_hours >= 24
                else "medium"
                if shipment.delay_hours >= 8
                else "high"
            ),
        }
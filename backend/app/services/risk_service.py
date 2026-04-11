from sqlalchemy.orm import Session

from app.models.exception_case import ExceptionCase
from app.repositories.shipment_repo import ShipmentRepository


class RiskService:
    def __init__(self, db: Session):
        self.db = db
        self.shipment_repo = ShipmentRepository(db)

    def calculate_risk_score(self, shipment_id: int) -> float:
        shipment = self.shipment_repo.get_by_id(shipment_id)
        if not shipment:
            raise ValueError(f"Shipment {shipment_id} not found")

        score = 0.1

        status = shipment.status.lower()

        if status in {"at risk", "customs delay"}:
            score += 0.30
        elif status == "delayed":
            score += 0.20
        elif status == "delivered":
            score = 0.05

        if shipment.delay_hours >= 12:
            score += 0.10
        if shipment.delay_hours >= 24:
            score += 0.15
        if shipment.delay_hours >= 48:
            score += 0.15

        active_exceptions = (
            self.db.query(ExceptionCase)
            .filter(
                ExceptionCase.shipment_id == shipment_id,
                ExceptionCase.is_active.is_(True),
            )
            .count()
        )

        score += min(active_exceptions * 0.10, 0.30)

        return round(min(score, 1.0), 2)

    def refresh_shipment_risk(self, shipment_id: int) -> float:
        shipment = self.shipment_repo.get_by_id(shipment_id)
        if not shipment:
            raise ValueError(f"Shipment {shipment_id} not found")

        shipment.risk_score = self.calculate_risk_score(shipment_id)
        self.shipment_repo.update_shipment(shipment)
        return shipment.risk_score
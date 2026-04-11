from sqlalchemy.orm import Session
from app.models.shipment import Shipment
from app.models.exception_case import ExceptionCase


class DashboardService:
    def __init__(self, db: Session):
        self.db = db

    def get_summary(self) -> dict:
        total_shipments = self.db.query(Shipment).count()
        delayed_shipments = self.db.query(Shipment).filter(Shipment.status == "Delayed").count()
        active_exceptions = (
            self.db.query(ExceptionCase)
            .filter(ExceptionCase.is_active.is_(True))
            .count()
        )
        high_risk_shipments = self.db.query(Shipment).filter(Shipment.risk_score >= 0.7).count()

        return {
            "total_shipments": total_shipments,
            "delayed_shipments": delayed_shipments,
            "active_exceptions": active_exceptions,
            "high_risk_shipments": high_risk_shipments,
        }
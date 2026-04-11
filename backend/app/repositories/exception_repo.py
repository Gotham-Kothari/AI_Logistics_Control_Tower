from datetime import datetime

from sqlalchemy.orm import Session

from app.models.exception_case import ExceptionCase


class ExceptionRepository:
    def __init__(self, db: Session):
        self.db = db

    def list_alerts(self) -> list[ExceptionCase]:
        return (
            self.db.query(ExceptionCase)
            .order_by(ExceptionCase.created_at.desc(), ExceptionCase.id.desc())
            .all()
        )

    def get_by_alert_id(self, alert_id: str) -> ExceptionCase | None:
        if not alert_id.startswith("ALT"):
            return None

        numeric_part = alert_id.replace("ALT", "").strip()
        if not numeric_part.isdigit():
            return None

        return (
            self.db.query(ExceptionCase)
            .filter(ExceptionCase.id == int(numeric_part))
            .first()
        )

    def acknowledge(self, alert: ExceptionCase) -> ExceptionCase:
        alert.is_acknowledged = True
        alert.acknowledged_at = datetime.utcnow()
        self.db.add(alert)
        self.db.commit()
        self.db.refresh(alert)
        return alert
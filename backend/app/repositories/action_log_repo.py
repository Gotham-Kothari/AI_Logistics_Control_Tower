from sqlalchemy.orm import Session

from app.models.action_log import ActionLog


class ActionLogRepository:
    def __init__(self, db: Session):
        self.db = db

    def list_logs(self) -> list[ActionLog]:
        return (
            self.db.query(ActionLog)
            .order_by(ActionLog.created_at.desc(), ActionLog.id.desc())
            .all()
        )

    def create_log(
        self,
        shipment_id: int,
        actor: str,
        note: str,
        action_type: str = "NOTE",
    ) -> ActionLog:
        log = ActionLog(
            shipment_id=shipment_id,
            actor=actor,
            note=note,
            action_type=action_type,
        )
        self.db.add(log)
        self.db.commit()
        self.db.refresh(log)
        return log
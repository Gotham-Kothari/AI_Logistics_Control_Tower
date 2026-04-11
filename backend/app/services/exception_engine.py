from sqlalchemy.orm import Session

from app.models.exception_case import ExceptionCase
from app.models.shipment import Shipment
from app.models.shipment_event import ShipmentEvent


class ExceptionEngineService:
    def __init__(self, db: Session):
        self.db = db

    def _find_open_exception(
        self,
        shipment_id: int,
        exception_type: str,
    ) -> ExceptionCase | None:
        return (
            self.db.query(ExceptionCase)
            .filter(
                ExceptionCase.shipment_id == shipment_id,
                ExceptionCase.exception_type == exception_type,
                ExceptionCase.is_active.is_(True),
            )
            .first()
        )

    def _create_exception(
        self,
        shipment_id: int,
        exception_type: str,
        severity: str,
        description: str,
    ) -> None:
        existing = self._find_open_exception(shipment_id, exception_type)
        if existing:
            return

        exception_case = ExceptionCase(
            shipment_id=shipment_id,
            exception_type=exception_type,
            severity=severity,
            description=description,
            is_active=True,
            is_acknowledged=False,
        )
        self.db.add(exception_case)
        self.db.commit()

    def _resolve_open_exceptions(self, shipment_id: int) -> None:
        open_cases = (
            self.db.query(ExceptionCase)
            .filter(
                ExceptionCase.shipment_id == shipment_id,
                ExceptionCase.is_active.is_(True),
            )
            .all()
        )
        for case in open_cases:
            case.is_active = False
        self.db.commit()

    def evaluate(self, shipment: Shipment, event: ShipmentEvent | None = None) -> None:
        normalized_status = shipment.status.lower()

        if normalized_status == "customs delay":
            self._create_exception(
                shipment.id,
                "CUSTOMS_DELAY",
                "high",
                "Shipment is facing customs-related delay.",
            )
            return

        if normalized_status == "at risk":
            self._create_exception(
                shipment.id,
                "AT_RISK",
                "high",
                "Shipment has been marked at risk.",
            )
            return

        if normalized_status == "delayed":
            self._create_exception(
                shipment.id,
                "DELAY",
                "medium",
                "Shipment delay detected.",
            )
            return

        if normalized_status == "delivered":
            self._resolve_open_exceptions(shipment.id)
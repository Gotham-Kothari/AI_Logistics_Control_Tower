from datetime import datetime

from app.models.action_log import ActionLog
from app.models.exception_case import ExceptionCase
from app.models.recommendation import Recommendation
from app.models.shipment import Shipment
from app.models.shipment_event import ShipmentEvent


class FlutterSerializer:
    @staticmethod
    def _format_eta_text(value: str | None) -> str:
        return value or "TBD"

    @staticmethod
    def _format_time(value: datetime | None) -> str:
        if value is None:
            return "Unknown"
        return value.strftime("%I:%M %p").lstrip("0")

    @staticmethod
    def _risk_label(score: float) -> str:
        if score >= 0.7:
            return "High"
        if score >= 0.35:
            return "Medium"
        return "Low"

    @classmethod
    def shipment(cls, shipment: Shipment) -> dict:
        return {
            "id": shipment.shipment_ref,
            "origin": shipment.origin,
            "destination": shipment.destination,
            "eta": cls._format_eta_text(shipment.eta_text),
            "risk": cls._risk_label(shipment.risk_score),
            "status": shipment.status,
        }

    @classmethod
    def event(cls, event: ShipmentEvent) -> dict:
        return {
            "id": f"EVT{event.id:03d}",
            "shipmentId": event.shipment.shipment_ref,
            "title": event.title,
            "description": event.description or "",
            "timestamp": cls._format_time(event.event_time),
        }

    @classmethod
    def action_log(cls, log: ActionLog) -> dict:
        return {
            "id": f"NOTE{log.id:03d}",
            "shipmentId": log.shipment.shipment_ref,
            "author": log.actor or "Operator",
            "note": log.note or "",
            "timestamp": cls._format_time(log.created_at),
        }

    @classmethod
    def alert(cls, exception_case: ExceptionCase) -> dict:
        shipment = exception_case.shipment
        route = f"{shipment.origin} → {shipment.destination}"
        impact = (
            exception_case.description
            or exception_case.exception_type.replace("_", " ").title()
        )

        return {
            "id": f"ALT{exception_case.id:03d}",
            "shipmentId": shipment.shipment_ref,
            "title": exception_case.exception_type.replace("_", " ").title(),
            "severity": exception_case.severity.title(),
            "route": route,
            "impact": impact,
            "updatedAt": cls._format_time(exception_case.created_at),
            "isAcknowledged": bool(exception_case.is_acknowledged),
        }

    @staticmethod
    def recommendation_payload(
        recommendation: Recommendation | None,
        shipment: Shipment,
    ) -> dict:
        message = (
            recommendation.summary
            if recommendation and recommendation.summary
            else f"Continue monitoring shipment {shipment.shipment_ref} and validate upcoming milestones."
        )
        return {"recommendation": message}
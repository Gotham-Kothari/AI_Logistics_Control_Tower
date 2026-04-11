import json

from sqlalchemy.orm import Session

from app.agents.graph import build_recommendation_graph
from app.models.recommendation import Recommendation
from app.repositories.shipment_repo import ShipmentRepository


class RecommendationService:
    def __init__(self, db: Session):
        self.db = db
        self.shipment_repo = ShipmentRepository(db)
        self.graph = build_recommendation_graph()

    def _store_recommendation(self, shipment_id: int, payload: dict) -> None:
        recommendation = Recommendation(
            shipment_id=shipment_id,
            summary=payload.get("summary"),
            risk_level=payload.get("risk_level"),
            risk_score=float(payload.get("risk_score") or 0.0),
            raw_output_json=json.dumps(payload, ensure_ascii=False),
        )
        self.db.add(recommendation)
        self.db.commit()

    def generate_recommendation(self, shipment_ref: str) -> dict:
        shipment = self.shipment_repo.get_by_ref(shipment_ref)
        if not shipment:
            raise ValueError(f"Shipment {shipment_ref} not found")

        shipment_context = self.shipment_repo.get_shipment_context(shipment_ref)

        state = {
            "shipment_id": shipment.id,
            "shipment_context": shipment_context,
        }

        result = self.graph.invoke(state)
        final_response = result["final_response"]

        actions = final_response.get("recommended_actions", [])
        top_recommendation = None

        if isinstance(actions, list) and actions:
            first = actions[0]
            if isinstance(first, dict):
                top_recommendation = first.get("action")

        final_response["shipment_id"] = shipment.id
        final_response["shipment_ref"] = shipment_ref
        final_response["recommendation"] = (
            top_recommendation
            or final_response.get("summary")
            or f"Continue monitoring shipment {shipment_ref} and validate upcoming milestones."
        )

        self._store_recommendation(shipment.id, final_response)

        return final_response
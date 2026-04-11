import json
from sqlalchemy.orm import Session
from app.models.recommendation import Recommendation


class RecommendationRepository:
    def __init__(self, db: Session):
        self.db = db

    def create_recommendation(
        self,
        shipment_id: int,
        summary: str | None,
        risk_level: str | None,
        risk_score: float,
        raw_output: dict,
    ) -> Recommendation:
        rec = Recommendation(
            shipment_id=shipment_id,
            summary=summary,
            risk_level=risk_level,
            risk_score=risk_score,
            raw_output_json=json.dumps(raw_output),
        )
        self.db.add(rec)
        self.db.commit()
        self.db.refresh(rec)
        return rec
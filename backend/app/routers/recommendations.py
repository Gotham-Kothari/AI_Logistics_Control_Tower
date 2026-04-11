from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.recommendations import RecommendationResponse
from app.services.recommendation_service import RecommendationService

router = APIRouter(prefix="/recommendations", tags=["Recommendations"])


@router.get("/{shipment_ref}", response_model=RecommendationResponse)
def get_recommendation(shipment_ref: str, db: Session = Depends(get_db)) -> dict:
    service = RecommendationService(db)

    try:
        result = service.generate_recommendation(shipment_ref)
        return result
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc
    except Exception:
        return {
            "shipment_id": 0,
            "shipment_ref": shipment_ref,
            "summary": f"{shipment_ref} recommendation could not be generated from the LLM path.",
            "risk_level": "medium",
            "risk_score": 0.35,
            "key_issues": ["Recommendation service fallback was triggered"],
            "recommended_actions": [
                {
                    "action": f"Continue monitoring shipment {shipment_ref} and validate upcoming milestones.",
                    "priority": "medium",
                    "reason": "Fallback response returned because full intelligence generation was unavailable",
                }
            ],
            "used_llm": False,
            "source": "router_fallback",
            "generated_at": None,
            "recommendation": f"Continue monitoring shipment {shipment_ref} and validate upcoming milestones.",
        }
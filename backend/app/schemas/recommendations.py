from typing import List, Literal
from pydantic import BaseModel


class RecommendedAction(BaseModel):
    action: str
    priority: Literal["low", "medium", "high"]
    reason: str


class RecommendationResponse(BaseModel):
    shipment_id: int
    shipment_ref: str | None = None
    summary: str | None = None
    risk_level: Literal["low", "medium", "high", "critical"] | None = None
    risk_score: float | None = None
    key_issues: List[str] = []
    recommended_actions: List[RecommendedAction] = []
    used_llm: bool = False
    source: str = "rule_based_fallback"
    generated_at: str | None = None
    recommendation: str | None = None
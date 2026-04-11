from typing import Any, Dict, List, TypedDict


class RecommendationGraphState(TypedDict, total=False):
    shipment_id: int
    shipment_context: Dict[str, Any]
    detected_issues: List[str]
    rule_based_risk_score: float
    llm_output: Dict[str, Any]
    final_response: Dict[str, Any]
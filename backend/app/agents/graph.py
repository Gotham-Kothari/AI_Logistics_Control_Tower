# import json
# from typing import Any

# from app.agents.llm import get_llm
# from app.agents.prompts import SYSTEM_PROMPT
# from app.agents.state import RecommendationGraphState
# from app.agents.tools import compute_rule_based_risk, detect_operational_issues
# from app.core.config import get_settings


# def _risk_level_from_score(score: float) -> str:
#     if score >= 0.85:
#         return "critical"
#     if score >= 0.70:
#         return "high"
#     if score >= 0.35:
#         return "medium"
#     return "low"


# def _fallback_actions(
#     shipment_context: dict[str, Any],
#     detected_issues: list[str],
# ) -> list[dict[str, str]]:
#     actions: list[dict[str, str]] = []
#     last_event_type = shipment_context.get("last_event_type")
#     exception_count = shipment_context.get("exception_count", 0)
#     delay_hours = shipment_context.get("delay_hours", 0)

#     if last_event_type == "CUSTOMS_HOLD":
#         actions.append(
#             {
#                 "action": "Review compliance documents and contact customs broker immediately",
#                 "priority": "high",
#                 "reason": "Latest event indicates a customs hold that may block clearance",
#             }
#         )

#     if last_event_type == "PORT_CONGESTION":
#         actions.append(
#             {
#                 "action": "Coordinate with carrier and evaluate alternate handling window",
#                 "priority": "medium",
#                 "reason": "Port congestion may create schedule slippage",
#             }
#         )

#     if delay_hours >= 24:
#         actions.append(
#             {
#                 "action": "Escalate shipment delay to operations team",
#                 "priority": "high",
#                 "reason": "Shipment delay has crossed 24 hours",
#             }
#         )

#     if exception_count > 0:
#         actions.append(
#             {
#                 "action": "Review open exception cases and assign owner",
#                 "priority": "high" if exception_count >= 2 else "medium",
#                 "reason": "Shipment has active exception cases that need action",
#             }
#         )

#     if not actions:
#         actions.append(
#             {
#                 "action": "Continue monitoring shipment and validate upcoming milestones",
#                 "priority": "low",
#                 "reason": "No severe operational disruption is currently visible",
#             }
#         )

#     return actions[:3]


# def _fallback_response(state: RecommendationGraphState) -> dict[str, Any]:
#     shipment_context = state.get("shipment_context", {})
#     detected_issues = state.get("detected_issues", [])
#     risk_score = state.get("rule_based_risk_score", 0.1)

#     shipment_ref = shipment_context.get("shipment_ref", "Unknown Shipment")
#     status = shipment_context.get("status", "Unknown Status")

#     summary = f"{shipment_ref} is currently in {status} state."
#     if detected_issues:
#         summary += f" Key operational concerns: {'; '.join(detected_issues[:3])}."

#     return {
#         "shipment_id": state.get("shipment_id"),
#         "summary": summary,
#         "risk_level": _risk_level_from_score(risk_score),
#         "risk_score": risk_score,
#         "key_issues": detected_issues,
#         "recommended_actions": _fallback_actions(shipment_context, detected_issues),
#     }


# def _safe_parse_llm_json(text: str) -> dict[str, Any] | None:
#     try:
#         return json.loads(text)
#     except Exception:
#         return None


# class RecommendationGraph:
#     def invoke(self, state: RecommendationGraphState) -> RecommendationGraphState:
#         shipment_context = state.get("shipment_context", {})

#         detected_issues = detect_operational_issues(shipment_context)
#         rule_based_risk_score = compute_rule_based_risk(
#             shipment_context,
#             detected_issues,
#         )

#         state["detected_issues"] = detected_issues
#         state["rule_based_risk_score"] = rule_based_risk_score

#         settings = get_settings()
#         llm_output: dict[str, Any] | None = None

#         if settings.api_key:
#             try:
#                 llm = get_llm()
#                 user_prompt = json.dumps(
#                     {
#                         "shipment_id": state.get("shipment_id"),
#                         "shipment_context": shipment_context,
#                         "detected_issues": detected_issues,
#                         "rule_based_risk_score": rule_based_risk_score,
#                     },
#                     ensure_ascii=False,
#                 )

#                 response = llm.invoke(
#                     [
#                         {"role": "system", "content": SYSTEM_PROMPT},
#                         {"role": "user", "content": user_prompt},
#                     ]
#                 )

#                 response_text = getattr(response, "content", "")
#                 if isinstance(response_text, list):
#                     response_text = "".join(
#                         item.get("text", "") if isinstance(item, dict) else str(item)
#                         for item in response_text
#                     )

#                 parsed = _safe_parse_llm_json(str(response_text))
#                 if isinstance(parsed, dict):
#                     llm_output = parsed
#             except Exception:
#                 llm_output = None

#         state["llm_output"] = llm_output or {}

#         if llm_output:
#             final_response = {
#                 "shipment_id": state.get("shipment_id"),
#                 "summary": llm_output.get("summary"),
#                 "risk_level": llm_output.get(
#                     "risk_level",
#                     _risk_level_from_score(rule_based_risk_score),
#                 ),
#                 "risk_score": llm_output.get("risk_score", rule_based_risk_score),
#                 "key_issues": llm_output.get("key_issues", detected_issues),
#                 "recommended_actions": llm_output.get(
#                     "recommended_actions",
#                     _fallback_actions(shipment_context, detected_issues),
#                 ),
#             }
#         else:
#             final_response = _fallback_response(state)

#         state["final_response"] = final_response
#         return state


# def build_recommendation_graph() -> RecommendationGraph:
#     return RecommendationGraph()

import json
from datetime import datetime, timezone
from typing import Any

from app.agents.llm import get_llm
from app.agents.prompts import SYSTEM_PROMPT
from app.agents.state import RecommendationGraphState
from app.agents.tools import compute_rule_based_risk, detect_operational_issues
from app.core.config import get_settings


def _risk_level_from_score(score: float) -> str:
    if score >= 0.85:
        return "critical"
    if score >= 0.70:
        return "high"
    if score >= 0.35:
        return "medium"
    return "low"


def _safe_float(value: Any, default: float) -> float:
    try:
        return float(value)
    except Exception:
        return default


def _normalize_priority(value: Any) -> str:
    normalized = str(value or "").strip().lower()
    if normalized in {"low", "medium", "high"}:
        return normalized
    return "medium"


def _normalize_actions(actions: Any) -> list[dict[str, str]]:
    if not isinstance(actions, list):
        return []

    normalized_actions: list[dict[str, str]] = []

    for item in actions[:3]:
        if not isinstance(item, dict):
            continue

        action = str(item.get("action") or "").strip()
        reason = str(item.get("reason") or "").strip()
        priority = _normalize_priority(item.get("priority"))

        if not action:
            continue

        normalized_actions.append(
            {
                "action": action,
                "priority": priority,
                "reason": reason or "Recommended based on current shipment context",
            }
        )

    return normalized_actions


def _fallback_actions(
    shipment_context: dict[str, Any],
    detected_issues: list[str],
) -> list[dict[str, str]]:
    actions: list[dict[str, str]] = []

    last_event_type = (shipment_context.get("last_event_type") or "").upper()
    exception_count = int(shipment_context.get("exception_count", 0) or 0)
    delay_hours = float(shipment_context.get("delay_hours", 0) or 0)
    status = (shipment_context.get("status") or "").lower()

    if last_event_type in {"CUSTOMS_DELAY", "CUSTOMS_HOLD"} or status == "customs delay":
        actions.append(
            {
                "action": "Review compliance documents and contact customs broker immediately",
                "priority": "high",
                "reason": "Latest shipment context indicates customs-related blockage",
            }
        )

    if last_event_type == "PORT_CONGESTION":
        actions.append(
            {
                "action": "Coordinate with carrier and evaluate alternate handling window",
                "priority": "medium",
                "reason": "Port congestion may create schedule slippage",
            }
        )

    if delay_hours >= 24 or status == "delayed":
        actions.append(
            {
                "action": "Escalate shipment delay to operations team",
                "priority": "high",
                "reason": "Shipment delay has crossed a meaningful threshold",
            }
        )

    if status == "at risk":
        actions.append(
            {
                "action": "Prepare contingency handling plan and monitor milestones closely",
                "priority": "high",
                "reason": "Shipment is explicitly marked at risk",
            }
        )

    if exception_count > 0:
        actions.append(
            {
                "action": "Review open exception cases and assign owner",
                "priority": "high" if exception_count >= 2 else "medium",
                "reason": "Shipment has active exception cases that need action",
            }
        )

    if status == "delivered":
        actions.append(
            {
                "action": "Close residual alerts and archive shipment activity",
                "priority": "low",
                "reason": "Shipment is already delivered",
            }
        )

    if not actions:
        actions.append(
            {
                "action": "Continue monitoring shipment and validate upcoming milestones",
                "priority": "low",
                "reason": "No severe operational disruption is currently visible",
            }
        )

    deduped: list[dict[str, str]] = []
    seen_actions: set[str] = set()

    for action in actions:
        action_text = action["action"].strip().lower()
        if action_text in seen_actions:
            continue
        seen_actions.add(action_text)
        deduped.append(action)

    return deduped[:3]


def _fallback_response(state: RecommendationGraphState) -> dict[str, Any]:
    shipment_context = state.get("shipment_context", {})
    detected_issues = state.get("detected_issues", [])
    risk_score = float(state.get("rule_based_risk_score", 0.1) or 0.1)

    shipment_ref = shipment_context.get("shipment_ref", "Unknown Shipment")
    status = shipment_context.get("status", "Unknown Status")

    summary = f"{shipment_ref} is currently in {status} state."
    if detected_issues:
        summary += f" Key operational concerns: {'; '.join(detected_issues[:3])}."

    actions = _fallback_actions(shipment_context, detected_issues)

    return {
        "shipment_id": state.get("shipment_id"),
        "shipment_ref": shipment_ref,
        "summary": summary,
        "risk_level": _risk_level_from_score(risk_score),
        "risk_score": risk_score,
        "key_issues": detected_issues,
        "recommended_actions": actions,
        "used_llm": False,
        "source": "rule_based_fallback",
        "generated_at": datetime.now(timezone.utc).isoformat(),
    }


def _safe_parse_llm_json(text: str) -> dict[str, Any] | None:
    try:
        return json.loads(text)
    except Exception:
        return None


class RecommendationGraph:
    def invoke(self, state: RecommendationGraphState) -> RecommendationGraphState:
        shipment_context = state.get("shipment_context", {})

        detected_issues = detect_operational_issues(shipment_context)
        rule_based_risk_score = compute_rule_based_risk(
            shipment_context,
            detected_issues,
        )

        state["detected_issues"] = detected_issues
        state["rule_based_risk_score"] = rule_based_risk_score

        settings = get_settings()
        llm_output: dict[str, Any] | None = None

        if settings.api_key:
            try:
                llm = get_llm()
                user_prompt = json.dumps(
                    {
                        "shipment_id": state.get("shipment_id"),
                        "shipment_context": shipment_context,
                        "detected_issues": detected_issues,
                        "rule_based_risk_score": rule_based_risk_score,
                    },
                    ensure_ascii=False,
                )

                response = llm.invoke(
                    [
                        {"role": "system", "content": SYSTEM_PROMPT},
                        {"role": "user", "content": user_prompt},
                    ]
                )

                response_text = getattr(response, "content", "")
                if isinstance(response_text, list):
                    response_text = "".join(
                        item.get("text", "") if isinstance(item, dict) else str(item)
                        for item in response_text
                    )

                parsed = _safe_parse_llm_json(str(response_text))
                if isinstance(parsed, dict):
                    llm_output = parsed
            except Exception:
                llm_output = None

        state["llm_output"] = llm_output or {}

        if llm_output:
            shipment_ref = shipment_context.get("shipment_ref")
            summary = str(llm_output.get("summary") or "").strip()
            if not summary:
                summary = _fallback_response(state)["summary"]

            risk_score = _safe_float(
                llm_output.get("risk_score"),
                rule_based_risk_score,
            )
            risk_score = round(min(max(risk_score, 0.0), 1.0), 2)

            risk_level = str(
                llm_output.get("risk_level") or _risk_level_from_score(risk_score)
            ).strip().lower()
            if risk_level not in {"low", "medium", "high", "critical"}:
                risk_level = _risk_level_from_score(risk_score)

            key_issues = llm_output.get("key_issues")
            if not isinstance(key_issues, list) or not key_issues:
                key_issues = detected_issues
            else:
                key_issues = [str(item).strip() for item in key_issues if str(item).strip()][:5]

            recommended_actions = _normalize_actions(llm_output.get("recommended_actions"))
            if not recommended_actions:
                recommended_actions = _fallback_actions(shipment_context, detected_issues)

            final_response = {
                "shipment_id": state.get("shipment_id"),
                "shipment_ref": shipment_ref,
                "summary": summary,
                "risk_level": risk_level,
                "risk_score": risk_score,
                "key_issues": key_issues,
                "recommended_actions": recommended_actions,
                "used_llm": True,
                "source": "llm",
                "generated_at": datetime.now(timezone.utc).isoformat(),
            }
        else:
            final_response = _fallback_response(state)

        state["final_response"] = final_response
        return state


def build_recommendation_graph() -> RecommendationGraph:
    return RecommendationGraph()
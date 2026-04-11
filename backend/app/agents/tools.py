# from typing import Any


# def detect_operational_issues(shipment_context: dict[str, Any]) -> list[str]:
#     issues: list[str] = []

#     if shipment_context.get("delay_hours", 0) >= 24:
#         issues.append("Shipment is delayed beyond 24 hours")

#     if shipment_context.get("exception_count", 0) > 0:
#         issues.append("Shipment has active exception cases")

#     if shipment_context.get("last_event_type") in {"DELAYED", "CUSTOMS_HOLD", "PORT_CONGESTION"}:
#         issues.append(
#             f"Latest event indicates operational disruption: {shipment_context.get('last_event_type')}"
#         )

#     if shipment_context.get("eta_confidence") == "low":
#         issues.append("Estimated arrival confidence is low")

#     return issues


# def compute_rule_based_risk(
#     shipment_context: dict[str, Any],
#     detected_issues: list[str],
# ) -> float:
#     score = 0.1

#     delay_hours = shipment_context.get("delay_hours", 0)
#     exception_count = shipment_context.get("exception_count", 0)
#     last_event_type = shipment_context.get("last_event_type")

#     if delay_hours >= 12:
#         score += 0.15
#     if delay_hours >= 24:
#         score += 0.20
#     if delay_hours >= 48:
#         score += 0.20

#     score += min(exception_count * 0.10, 0.30)

#     if last_event_type == "CUSTOMS_HOLD":
#         score += 0.20
#     elif last_event_type == "PORT_CONGESTION":
#         score += 0.15
#     elif last_event_type == "DELAYED":
#         score += 0.10

#     if len(detected_issues) >= 3:
#         score += 0.10

#     return round(min(score, 1.0), 2)

from typing import Any


def detect_operational_issues(shipment_context: dict[str, Any]) -> list[str]:
    issues: list[str] = []

    delay_hours = float(shipment_context.get("delay_hours", 0) or 0)
    exception_count = int(shipment_context.get("exception_count", 0) or 0)
    last_event_type = (shipment_context.get("last_event_type") or "").upper()
    eta_confidence = (shipment_context.get("eta_confidence") or "").lower()
    status = (shipment_context.get("status") or "").lower()

    if delay_hours >= 24:
        issues.append("Shipment is delayed beyond 24 hours")
    elif delay_hours >= 12:
        issues.append("Shipment has material delay exposure")

    if exception_count > 0:
        issues.append("Shipment has active exception cases")

    if last_event_type in {"DELAYED", "CUSTOMS_DELAY", "CUSTOMS_HOLD", "PORT_CONGESTION", "AT_RISK"}:
        issues.append(f"Latest event indicates operational disruption: {last_event_type}")

    if eta_confidence == "low":
        issues.append("Estimated arrival confidence is low")

    if status in {"customs delay", "at risk"}:
        issues.append(f"Shipment status is currently {status}")

    deduped: list[str] = []
    for issue in issues:
        if issue not in deduped:
            deduped.append(issue)

    return deduped


def compute_rule_based_risk(
    shipment_context: dict[str, Any],
    detected_issues: list[str],
) -> float:
    score = 0.10

    delay_hours = float(shipment_context.get("delay_hours", 0) or 0)
    exception_count = int(shipment_context.get("exception_count", 0) or 0)
    last_event_type = (shipment_context.get("last_event_type") or "").upper()
    status = (shipment_context.get("status") or "").lower()

    if delay_hours >= 12:
        score += 0.15
    if delay_hours >= 24:
        score += 0.20
    if delay_hours >= 48:
        score += 0.20

    score += min(exception_count * 0.10, 0.30)

    if last_event_type in {"CUSTOMS_DELAY", "CUSTOMS_HOLD"}:
        score += 0.20
    elif last_event_type == "PORT_CONGESTION":
        score += 0.15
    elif last_event_type in {"DELAYED", "AT_RISK"}:
        score += 0.10

    if status == "customs delay":
        score += 0.15
    elif status == "at risk":
        score += 0.10
    elif status == "delayed":
        score += 0.08
    elif status == "delivered":
        score = min(score, 0.10)

    if len(detected_issues) >= 3:
        score += 0.10

    return round(min(score, 1.0), 2)
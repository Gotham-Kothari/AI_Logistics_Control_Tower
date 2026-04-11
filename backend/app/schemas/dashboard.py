from pydantic import BaseModel

class DashboardSummary(BaseModel):
    total_shipments: int
    delayed_shipments: int
    active_exceptions: int
    high_risk_shipments: int

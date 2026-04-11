from datetime import datetime

from sqlalchemy import DateTime, Float, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base


class Shipment(Base):
    __tablename__ = "shipments"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    shipment_ref: Mapped[str] = mapped_column(String(100), unique=True, index=True)

    origin: Mapped[str] = mapped_column(String(100))
    destination: Mapped[str] = mapped_column(String(100))
    carrier: Mapped[str] = mapped_column(String(100), default="ControlHub Carrier")

    status: Mapped[str] = mapped_column(String(50), default="In Transit")
    eta_text: Mapped[str | None] = mapped_column(String(50), nullable=True)
    current_location: Mapped[str | None] = mapped_column(String(100), nullable=True)

    delay_hours: Mapped[float] = mapped_column(Float, default=0.0)
    risk_score: Mapped[float] = mapped_column(Float, default=0.35)

    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
    )

    events = relationship(
        "ShipmentEvent",
        back_populates="shipment",
        cascade="all, delete-orphan",
        order_by="ShipmentEvent.event_time.desc()",
    )
    exceptions = relationship(
        "ExceptionCase",
        back_populates="shipment",
        cascade="all, delete-orphan",
        order_by="ExceptionCase.created_at.desc()",
    )
    recommendations = relationship(
        "Recommendation",
        back_populates="shipment",
        cascade="all, delete-orphan",
        order_by="Recommendation.created_at.desc()",
    )
    action_logs = relationship(
        "ActionLog",
        back_populates="shipment",
        cascade="all, delete-orphan",
        order_by="ActionLog.created_at.desc()",
    )
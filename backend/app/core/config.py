from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "AI Logistics Control Tower"
    app_env: str = "development"
    debug: bool = True

    app_host: str = "0.0.0.0"
    app_port: int = 8000
    api_prefix: str = "/api"

    database_url: str = "sqlite:///./control_tower.db"

    allow_origins: list[str] = Field(
        default_factory=lambda: ["*"]
    )

    api_key: str | None = None
    model: str = "claude-sonnet-4-6"
    temperature: float = 0.0
    max_tokens: int = 1200

    langsmith_tracing: bool = False
    langsmith_api_key: str | None = None
    langsmith_project: str | None = None

    max_recommendations: int = 3
    risk_alert_threshold: float = 0.7

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()
from langchain_anthropic import ChatAnthropic

from app.core.config import get_settings


def get_llm() -> ChatAnthropic:
    settings = get_settings()

    return ChatAnthropic(
        model=settings.model,
        temperature=settings.temperature,
        max_tokens=settings.max_tokens,
        api_key=settings.api_key,
    )
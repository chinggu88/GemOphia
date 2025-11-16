"""
Configuration settings for AI backend
"""
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings"""

    # App
    app_name: str = "GemOphia AI Backend"
    debug: bool = True
    host: str = "0.0.0.0"
    port: int = 8000

    # Supabase
    supabase_url: str
    supabase_key: str
    supabase_service_key: str | None = None

    # AI APIs
    ai_provider: str = "gemini"  # gemini, openai, anthropic
    gemini_api_key: str | None = None
    openai_api_key: str | None = None
    anthropic_api_key: str | None = None

    # Redis (Optional)
    redis_url: str = "redis://localhost:6379"

    # CORS
    allowed_origins: list[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
    ]

    class Config:
        env_file = ".env"
        case_sensitive = False


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance"""
    return Settings()

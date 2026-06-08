"""Application configuration using pydantic-settings."""

from typing import List
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    # ─── App ───────────────────────────────────────────
    APP_NAME: str = "AppointEase"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False

    # ─── Database ──────────────────────────────────────
    # Default: SQLite for local dev (no setup needed)
    # Override with PostgreSQL URL in .env
    DATABASE_URL: str = "sqlite+aiosqlite:///./appointment.db"

    # ─── Redis ─────────────────────────────────────────
    REDIS_URL: str = "redis://localhost:6379/0"

    # ─── JWT ───────────────────────────────────────────
    SECRET_KEY: str = "your-super-secret-key-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # ─── CORS ──────────────────────────────────────────
    CORS_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:5173"]
    FRONTEND_URL: str = "http://localhost:3000"
    BACKEND_URL: str = "http://localhost:8000"

    # ─── SMTP / Email ──────────────────────────────────
    # Leave empty to disable email (app still works)
    SMTP_HOST: str = ""
    SMTP_PORT: int = 587
    SMTP_USER: str = ""
    SMTP_PASS: str = ""
    EMAIL_FROM: str = "AppointEase <no-reply@appointease.local>"

    # ─── Razorpay ──────────────────────────────────────
    # Leave empty to disable payments
    RAZORPAY_KEY_ID: str = ""
    RAZORPAY_KEY_SECRET: str = ""
    RAZORPAY_WEBHOOK_SECRET: str = ""

    # ─── Google OAuth ──────────────────────────────────
    # Leave empty to disable Google login
    GOOGLE_CLIENT_ID: str = ""
    GOOGLE_CLIENT_SECRET: str = ""

    # ─── Google Calendar ───────────────────────────────
    # Leave empty to disable calendar integration
    GOOGLE_CALENDAR_CLIENT_ID: str = ""
    GOOGLE_CALENDAR_CLIENT_SECRET: str = ""

    # ─── Microsoft OAuth ───────────────────────────────
    # Leave empty to disable Microsoft login
    MICROSOFT_CLIENT_ID: str = ""
    MICROSOFT_CLIENT_SECRET: str = ""

    # ─── AI Chat ───────────────────────────────────────
    # Leave empty to disable AI chat (falls back gracefully)
    GROK_API_KEY: str = ""
    GROK_MODEL: str = "grok-3-mini"
    GEMINI_API_KEY: str = ""

    # ─── Rate Limiting ─────────────────────────────────
    RATE_LIMIT_PER_MINUTE: int = 60
    RATE_LIMIT_AUTH_PER_MINUTE: int = 10


settings = Settings()

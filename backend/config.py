import os
from datetime import timedelta

class Config:
    # core
    SECRET_KEY = os.getenv("SECRET_KEY", "dev-secret-change-me")
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL", "sqlite:///data.db")
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # jwt
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "dev-jwt-secret-change-me")
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=8)
    ENFORCE_AUTH = os.getenv("ENFORCE_AUTH", "false").lower() == "true"

    # cors — allow frontend on 8443
    CORS_ORIGINS = [
        os.getenv("FRONTEND_ORIGIN", "http://localhost:8443")
    ]

    # optional API keys (used by subfinder/amass when you wire them)
    SUBFINDER_API_KEYS = {
        "virustotal": os.getenv("VT_API_KEY"),
        "securitytrails": os.getenv("SECURITYTRAILS_API_KEY"),
        "censys_id": os.getenv("CENSYS_ID"),
        "censys_secret": os.getenv("CENSYS_SECRET"),
        "shodan": os.getenv("SHODAN_API_KEY"),
    }

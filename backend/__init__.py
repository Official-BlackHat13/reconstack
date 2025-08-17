from flask import Flask
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from .config import Config

db = SQLAlchemy()
jwt = JWTManager()

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    # CORS (allow frontend on 8443)
    CORS(app, resources={r"/api/*": {"origins": Config.CORS_ORIGINS}})

    # DB + JWT
    db.init_app(app)
    jwt.init_app(app)

    with app.app_context():
        from . import models  # noqa: F401
        db.create_all()

        # register blueprints
        from .routes.auth import bp as auth_bp
        from .routes.domains import bp as domains_bp
        from .routes.cves import bp as cves_bp
        from .routes.subdomains import bp as subdomains_bp
        from .routes.urls import bp as urls_bp

        app.register_blueprint(auth_bp, url_prefix="/api/auth")
        app.register_blueprint(domains_bp, url_prefix="/api/domains")
        app.register_blueprint(subdomains_bp, url_prefix="/api/subdomains")
        app.register_blueprint(urls_bp, url_prefix="/api/urls")
        app.register_blueprint(cves_bp, url_prefix="/api/cves")

    @app.get("/api/health")
    def health():
        return {"status": "ok"}

    return app

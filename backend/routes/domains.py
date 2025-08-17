from flask import Blueprint, request
from flask_jwt_extended import verify_jwt_in_request, get_jwt_identity
from ..config import Config
from ..models import Domain, Subdomain
from .. import db
from ..services.scanner import enumerate_subdomains_stub

bp = Blueprint("domains", __name__)

def _maybe_auth():
    # Optional JWT during development
    if Config.ENFORCE_AUTH:
        verify_jwt_in_request()
        get_jwt_identity()

@bp.get("/")
def list_domains():
    _maybe_auth()
    domains = Domain.query.order_by(Domain.id.desc()).all()
    return {"domains": [{"id": d.id, "name": d.name} for d in domains]}

@bp.post("/")
def add_domain():
    _maybe_auth()
    data = request.get_json(silent=True) or {}
    name = (data.get("name") or "").strip().lower()
    if not name:
        return {"message": "name required"}, 400

    existing = Domain.query.filter_by(name=name).first()
    if existing:
        return {"id": existing.id, "name": existing.name}, 200

    d = Domain(name=name)
    db.session.add(d)
    db.session.commit()

    # Stub: enumerate subdomains (replace with real tools later)
    subs = enumerate_subdomains_stub(name)
    for s in subs:
        db.session.add(Subdomain(name=s["name"], status_code=s.get("status_code"), domain_id=d.id))
    db.session.commit()

    return {"id": d.id, "name": d.name}, 201

@bp.get("/<int:domain_id>")
def get_domain(domain_id):
    _maybe_auth()
    d = Domain.query.get_or_404(domain_id)
    return {"id": d.id, "name": d.name}

@bp.get("/<int:domain_id>/subdomains")
def domain_subdomains(domain_id):
    _maybe_auth()
    Domain.query.get_or_404(domain_id)
    subs = Subdomain.query.filter_by(domain_id=domain_id).all()
    def color_for(code):
        if code == 200: return "green"
        if code == 403: return "orange"
        if code and code >= 500: return "red"
        return "gray"
    return {
        "subdomains": [
            {"id": s.id, "name": s.name, "status_code": s.status_code, "status_color": color_for(s.status_code)}
            for s in subs
        ]
    }

from flask import Blueprint, request
from flask_jwt_extended import verify_jwt_in_request, get_jwt_identity
from ..config import Config
from ..models import CVE
from .. import db

bp = Blueprint("cves", __name__)

def _maybe_auth():
    if Config.ENFORCE_AUTH:
        verify_jwt_in_request()
        get_jwt_identity()

@bp.get("/")
def list_cves():
    _maybe_auth()
    cves = CVE.query.order_by(CVE.id.desc()).all()
    return {
        "cves": [{"id": c.id, "cve_id": c.cve_id, "severity": c.severity, "url": c.url, "subdomain_id": c.subdomain_id} for c in cves]
    }

@bp.post("/")
def add_cve():
    _maybe_auth()
    data = request.get_json(silent=True) or {}
    cve_id = (data.get("cve_id") or "").strip().upper()
    subdomain_id = data.get("subdomain_id")
    if not cve_id or not subdomain_id:
        return {"message": "cve_id and subdomain_id required"}, 400
    c = CVE(cve_id=cve_id, severity=data.get("severity"), url=data.get("url"), subdomain_id=subdomain_id)
    db.session.add(c)
    db.session.commit()
    return {"id": c.id}, 201

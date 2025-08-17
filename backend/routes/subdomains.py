from flask import Blueprint
from flask_jwt_extended import verify_jwt_in_request, get_jwt_identity
from ..config import Config
from ..models import Subdomain, Url, CVE

bp = Blueprint("subdomains", __name__)

def _maybe_auth():
    if Config.ENFORCE_AUTH:
        verify_jwt_in_request()
        get_jwt_identity()

@bp.get("/<int:subdomain_id>")
def subdomain_detail(subdomain_id):
    _maybe_auth()
    s = Subdomain.query.get_or_404(subdomain_id)
    urls = Url.query.filter_by(subdomain_id=s.id).all()
    cves = CVE.query.filter_by(subdomain_id=s.id).all()
    return {
        "id": s.id,
        "name": s.name,
        "status_code": s.status_code,
        "urls": [{"id": u.id, "url": u.url} for u in urls],
        "cves": [{"id": c.id, "cve_id": c.cve_id, "severity": c.severity, "url": c.url} for c in cves],
    }
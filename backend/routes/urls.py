from flask import Blueprint
from flask_jwt_extended import verify_jwt_in_request, get_jwt_identity
from ..config import Config
from ..models import Url

bp = Blueprint("urls", __name__)

def _maybe_auth():
    if Config.ENFORCE_AUTH:
        verify_jwt_in_request()
        get_jwt_identity()

@bp.get("/by-subdomain/<int:subdomain_id>")
def list_urls(subdomain_id):
    _maybe_auth()
    urls = Url.query.filter_by(subdomain_id=subdomain_id).all()
    return {"urls": [{"id": u.id, "url": u.url} for u in urls]}
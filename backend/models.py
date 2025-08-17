from . import db
from datetime import datetime

class Domain(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(253), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    subdomains = db.relationship("Subdomain", backref="domain", cascade="all, delete-orphan")

class Subdomain(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(253), nullable=False, index=True)
    status_code = db.Column(db.Integer, nullable=True)
    domain_id = db.Column(db.Integer, db.ForeignKey("domain.id"), nullable=False)
    urls = db.relationship("Url", backref="subdomain", cascade="all, delete-orphan")
    cves = db.relationship("CVE", backref="subdomain", cascade="all, delete-orphan")

class Url(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    url = db.Column(db.Text, nullable=False)
    subdomain_id = db.Column(db.Integer, db.ForeignKey("subdomain.id"), nullable=False)

class CVE(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    cve_id = db.Column(db.String(32), nullable=False, index=True)  # e.g., CVE-2024-1234
    severity = db.Column(db.String(16), nullable=True)             # High/Medium/Low
    url = db.Column(db.Text, nullable=True)                        # optional URL hit
    subdomain_id = db.Column(db.Integer, db.ForeignKey("subdomain.id"), nullable=False)

class ScanLog(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    domain_id = db.Column(db.Integer, db.ForeignKey("domain.id"), nullable=True)
    target = db.Column(db.String(512), nullable=False)   # domain or subdomain
    tool = db.Column(db.String(64), nullable=False)      # subfinder/amass/httpx/nuclei
    templates = db.Column(db.Text, nullable=True)
    status = db.Column(db.String(16), default="done")    # done/failed/running
    duration_ms = db.Column(db.Integer, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

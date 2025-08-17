from flask import Blueprint, request
from flask_jwt_extended import create_access_token
from ..config import Config

bp = Blueprint("auth", __name__)

# Hardcoded user (as requested earlier)
VALID_USER = {"username": "BlackHat13", "password": "Kali@143"}

@bp.post("/login")
def login():
    data = request.get_json(silent=True) or {}
    if data.get("username") == VALID_USER["username"] and data.get("password") == VALID_USER["password"]:
        token = create_access_token(identity=data["username"])
        return {"access_token": token}, 200
    return {"message": "Invalid credentials"}, 401

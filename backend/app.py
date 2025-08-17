from . import create_app

app = create_app()

if __name__ == "__main__":
    # Backend stays on 5000; frontend is on 8443 (CORS already set)
    app.run(host="0.0.0.0", port=5000, debug=True)

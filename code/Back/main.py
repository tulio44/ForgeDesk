from flask import Flask, jsonify
from flask_cors import CORS

from api.solicitacoes import solicitacoes_bp
from core.config import FLASK_PORT
from database.database import Base, engine
from models.solicitacao import Solicitacao


app = Flask(__name__)
CORS(app)

Base.metadata.create_all(bind=engine)

app.register_blueprint(solicitacoes_bp)


@app.get("/health")
def health():
    return jsonify({
        "status": "ok",
        "app": "ForgeDesk API"
    }), 200


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=FLASK_PORT,
        debug=True
    )
"""Flask API for the Sign Language Translator."""
import base64
import os
from flask import Flask, jsonify, request

from .database import Database
from .preprocess import FEATURES, build_sequence

BASE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(BASE)


def create_app(config=None):
    cfg = {
        "MODELS_DIR": os.path.join(ROOT, "models"),
        "DB_PATH": os.path.join(BASE, "data", "app.db"),
        "VOCAB_PATH": os.path.join(BASE, "data", "vocabulary.json"),
        "THRESHOLD": float(os.environ.get("THRESHOLD", 0.8)),
        "PREDICTOR": None,  # tests can inject a fake predictor
    }
    cfg.update(config or {})
    app = Flask(__name__)
    app.config.update(cfg)
    db = Database(cfg["DB_PATH"], cfg["VOCAB_PATH"])
    state = {"predictor": cfg["PREDICTOR"]}

    def predictor():
        if state["predictor"] is None:
            from .predictor import Predictor
            state["predictor"] = Predictor.from_dir(cfg["MODELS_DIR"])
        return state["predictor"]

    def error(msg, code=400):
        return jsonify({"error": msg}), code

    @app.get("/api/health")
    def health():
        ready = state["predictor"] is not None or os.path.exists(
            os.path.join(cfg["MODELS_DIR"], "sign_model.keras"))
        return jsonify({"status": "ok", "model_ready": ready})

    @app.get("/api/signs")
    def signs():
        return jsonify(db.get_signs())

    def _respond(frames):
        label, conf = predictor().predict(frames)
        ok = conf >= app.config["THRESHOLD"]
        if ok:
            db.add_history(label, conf)
        return jsonify({"label": label if ok else None, "confidence": round(conf, 4),
                        "recognized": ok, "threshold": app.config["THRESHOLD"]})

    @app.post("/api/predict")
    def predict():
        data = request.get_json(silent=True) or {}
        frames = data.get("frames")
        if not isinstance(frames, list) or not frames:
            return error("'frames' must be a non-empty list of 126-value landmark frames")
        try:
            build_sequence(frames)  # validates shape before running the model
            return _respond(frames)
        except (ValueError, TypeError) as e:
            return error(str(e))

    @app.post("/api/predict_images")
    def predict_images():
        """Accepts base64 JPEG frames; landmarks are extracted on the server."""
        data = request.get_json(silent=True) or {}
        images = data.get("images")
        if not isinstance(images, list) or not images:
            return error("'images' must be a non-empty list of base64 JPEG strings")
        try:
            from .landmarks import extract_from_jpeg
            frames = [extract_from_jpeg(base64.b64decode(i)) for i in images]
            return _respond(frames)
        except ImportError:
            return error("mediapipe/opencv are not installed on the server", 501)
        except Exception as e:  # bad base64 / bad image
            return error(str(e))

    @app.get("/api/history")
    def history():
        return jsonify(db.get_history(int(request.args.get("limit", 100))))

    @app.delete("/api/history")
    def clear_history():
        db.clear_history()
        return jsonify({"cleared": True})

    return app


if __name__ == "__main__":
    create_app().run(host="0.0.0.0", port=5000)

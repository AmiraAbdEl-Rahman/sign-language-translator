"""Smoke test with the real trained model (skipped if no model has been trained)."""
import os
import sys
import numpy as np
import pytest

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "ml"))
MODEL = os.path.join(ROOT, "models", "sign_model.keras")


@pytest.mark.skipif(not os.path.exists(MODEL), reason="no trained model")
def test_real_model_predicts_demo_samples():
    from backend.predictor import Predictor
    from make_demo_data import make_sequence
    from common import load_words
    p = Predictor.from_dir(os.path.join(ROOT, "models"))
    rng = np.random.default_rng(123)
    for w in load_words():
        label, conf = p.predict(make_sequence(w, rng))
        assert label == w and conf > 0.8


@pytest.mark.skipif(not os.path.exists(MODEL), reason="no trained model")
def test_api_with_real_model(tmp_path):
    from backend.app import create_app
    from make_demo_data import make_sequence
    app = create_app({"DB_PATH": str(tmp_path / "t.db")})
    c = app.test_client()
    seq = make_sequence("Doctor", np.random.default_rng(5)).tolist()
    r = c.post("/api/predict", json={"frames": seq})
    assert r.json["label"] == "Doctor"

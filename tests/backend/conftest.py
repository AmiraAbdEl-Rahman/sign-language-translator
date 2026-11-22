import os
import sys
import pytest
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
from backend.app import create_app  # noqa: E402


class FakePredictor:
    def __init__(self, label="Hello", conf=0.93):
        self.label, self.conf = label, conf

    def predict(self, frames):
        return self.label, self.conf


@pytest.fixture
def client(tmp_path):
    app = create_app({"DB_PATH": str(tmp_path / "t.db"), "PREDICTOR": FakePredictor()})
    return app.test_client()


@pytest.fixture
def low_conf_client(tmp_path):
    app = create_app({"DB_PATH": str(tmp_path / "t.db"), "PREDICTOR": FakePredictor(conf=0.5)})
    return app.test_client()

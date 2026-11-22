import json
import os
import sys
import numpy as np

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)
from backend.preprocess import build_sequence, SEQ_LEN, FEATURES  # noqa: E402

VOCAB_PATH = os.path.join(ROOT, "backend", "data", "vocabulary.json")
MODELS_DIR = os.path.join(ROOT, "models")
REPORTS_DIR = os.path.join(ROOT, "reports")


def load_words():
    with open(VOCAB_PATH, encoding="utf-8") as f:
        return [s["label_en"] for s in json.load(f)]


def load_dataset(data_dir):
    """Folder layout: <data_dir>/<Word>/<anything>.npy, each file shaped (frames, 126)."""
    words = load_words()
    X, y = [], []
    for idx, w in enumerate(words):
        folder = os.path.join(data_dir, w)
        if not os.path.isdir(folder):
            raise FileNotFoundError(f"missing folder for word '{w}': {folder}")
        for fn in sorted(os.listdir(folder)):
            if fn.endswith(".npy"):
                X.append(build_sequence(np.load(os.path.join(folder, fn))))
                y.append(idx)
    return np.stack(X), np.array(y), words

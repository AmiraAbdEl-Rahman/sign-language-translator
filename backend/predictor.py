import json
import os
import numpy as np
from .preprocess import build_sequence, SEQ_LEN, FEATURES


class Predictor:
    """Loads the trained Keras model and turns a landmark sequence into a word."""

    def __init__(self, model_path: str, labels_path: str):
        import tensorflow as tf  # heavy import, keep local
        self.model = tf.keras.models.load_model(model_path)
        with open(labels_path, encoding="utf-8") as f:
            self.labels = json.load(f)
        if self.model.output_shape[-1] != len(self.labels):
            raise ValueError("model outputs do not match labels.json")

    def predict(self, frames):
        seq = build_sequence(frames)                       # (30, 126)
        probs = self.model.predict(seq[None, ...], verbose=0)[0]
        idx = int(np.argmax(probs))
        return self.labels[idx], float(probs[idx])

    @classmethod
    def from_dir(cls, models_dir: str):
        return cls(os.path.join(models_dir, "sign_model.keras"),
                   os.path.join(models_dir, "labels.json"))

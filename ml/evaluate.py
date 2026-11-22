"""Evaluate the saved model on the held-out test split."""
import json
import os
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import tensorflow as tf
from sklearn.metrics import classification_report, confusion_matrix
from common import MODELS_DIR, REPORTS_DIR


def main():
    model = tf.keras.models.load_model(os.path.join(MODELS_DIR, "sign_model.keras"))
    words = json.load(open(os.path.join(MODELS_DIR, "labels.json"), encoding="utf-8"))
    d = np.load(os.path.join(REPORTS_DIR, "test_split.npz"))
    pred = model.predict(d["X"], verbose=0).argmax(1)
    rep = classification_report(d["y"], pred, target_names=words, digits=3)
    print(rep)
    open(os.path.join(REPORTS_DIR, "classification_report.txt"), "w").write(rep)
    cm = confusion_matrix(d["y"], pred)
    fig, ax = plt.subplots(figsize=(6, 5))
    ax.imshow(cm, cmap="Blues")
    ax.set_xticks(range(len(words)), words, rotation=45, ha="right")
    ax.set_yticks(range(len(words)), words)
    for i in range(len(words)):
        for j in range(len(words)):
            ax.text(j, i, cm[i, j], ha="center", va="center", fontsize=8)
    ax.set_xlabel("Predicted"); ax.set_ylabel("True"); ax.set_title("Confusion matrix (test split)")
    fig.tight_layout()
    fig.savefig(os.path.join(REPORTS_DIR, "confusion_matrix.png"), dpi=150)


if __name__ == "__main__":
    main()

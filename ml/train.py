"""Train the LSTM sign classifier.  Usage: python ml/train.py --data data/demo"""
import argparse
import json
import os
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
from common import load_dataset, MODELS_DIR, REPORTS_DIR, SEQ_LEN, FEATURES


def augment(X, rng):
    """Light augmentation: jitter, random scale and small time shift."""
    out = X.copy()
    out += rng.normal(0, 0.01, X.shape).astype(np.float32)
    out *= rng.uniform(0.9, 1.1, (len(X), 1, 1)).astype(np.float32)
    for i in range(len(out)):
        out[i] = np.roll(out[i], rng.integers(-2, 3), axis=0)
    return out


def build_model(n_classes):
    return tf.keras.Sequential([
        tf.keras.layers.Input(shape=(SEQ_LEN, FEATURES)),
        tf.keras.layers.LSTM(64, return_sequences=True),
        tf.keras.layers.LSTM(128),
        tf.keras.layers.Dense(64, activation="relu"),
        tf.keras.layers.Dropout(0.3),
        tf.keras.layers.Dense(n_classes, activation="softmax"),
    ])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", required=True)
    ap.add_argument("--epochs", type=int, default=100)
    ap.add_argument("--batch", type=int, default=32)
    ap.add_argument("--seed", type=int, default=42)
    a = ap.parse_args()
    tf.keras.utils.set_random_seed(a.seed)
    rng = np.random.default_rng(a.seed)

    X, y, words = load_dataset(a.data)
    X_tr, X_tmp, y_tr, y_tmp = train_test_split(X, y, test_size=0.30, stratify=y, random_state=a.seed)
    X_val, X_te, y_val, y_te = train_test_split(X_tmp, y_tmp, test_size=0.50, stratify=y_tmp, random_state=a.seed)
    X_tr = np.concatenate([X_tr, augment(X_tr, rng)])
    y_tr = np.concatenate([y_tr, y_tr])
    print(f"train={len(X_tr)} val={len(X_val)} test={len(X_te)} classes={len(words)}")

    model = build_model(len(words))
    model.compile(optimizer=tf.keras.optimizers.Adam(1e-3),
                  loss="sparse_categorical_crossentropy", metrics=["accuracy"])
    cb = [tf.keras.callbacks.EarlyStopping(patience=10, restore_best_weights=True, monitor="val_loss")]
    hist = model.fit(X_tr, y_tr, validation_data=(X_val, y_val), epochs=a.epochs,
                     batch_size=a.batch, callbacks=cb, verbose=2)

    os.makedirs(MODELS_DIR, exist_ok=True)
    os.makedirs(REPORTS_DIR, exist_ok=True)
    model.save(os.path.join(MODELS_DIR, "sign_model.keras"))
    with open(os.path.join(MODELS_DIR, "labels.json"), "w", encoding="utf-8") as f:
        json.dump(words, f, ensure_ascii=False)
    np.savez(os.path.join(REPORTS_DIR, "test_split.npz"), X=X_te, y=y_te)
    with open(os.path.join(REPORTS_DIR, "training_history.json"), "w") as f:
        json.dump({k: [float(v) for v in vs] for k, vs in hist.history.items()}, f)
    loss, acc = model.evaluate(X_te, y_te, verbose=0)
    print(f"test accuracy: {acc:.4f}")


if __name__ == "__main__":
    main()

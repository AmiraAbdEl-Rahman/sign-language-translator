"""Pre-processing shared by the backend and the training scripts.

A *frame* is a flat vector of 126 values: 2 hands x 21 landmarks x (x, y, z).
Missing hands are all zeros.
"""
import numpy as np

SEQ_LEN = 30
N_LANDMARKS = 21
FEATURES = 2 * N_LANDMARKS * 3  # 126
MIDDLE_MCP = 9  # middle-finger knuckle, used as the scale reference


def normalize_frame(frame) -> np.ndarray:
    """Make each hand relative to its wrist and scale by wrist->middle knuckle."""
    v = np.asarray(frame, dtype=np.float32).reshape(2, N_LANDMARKS, 3).copy()
    for h in range(2):
        pts = v[h]
        if not np.any(pts):
            continue
        pts -= pts[0]
        scale = float(np.linalg.norm(pts[MIDDLE_MCP]))
        v[h] = pts / (scale if scale > 1e-6 else 1.0)
    return v.reshape(-1)


def build_sequence(frames, seq_len: int = SEQ_LEN) -> np.ndarray:
    """Turn a list of raw frames into a normalized (seq_len, 126) array."""
    arr = np.asarray(frames, dtype=np.float32)
    if arr.ndim != 2 or arr.shape[1] != FEATURES:
        raise ValueError(f"frames must have shape (n, {FEATURES}), got {arr.shape}")
    if len(arr) == 0:
        raise ValueError("frames is empty")
    if len(arr) >= seq_len:
        idx = np.linspace(0, len(arr) - 1, seq_len).round().astype(int)
        arr = arr[idx]
    else:
        pad = np.repeat(arr[-1:], seq_len - len(arr), axis=0)
        arr = np.concatenate([arr, pad], axis=0)
    return np.stack([normalize_frame(f) for f in arr])

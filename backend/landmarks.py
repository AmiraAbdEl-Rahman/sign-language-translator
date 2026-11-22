"""Hand landmark extraction with MediaPipe (used for images and data collection)."""
import numpy as np
from .preprocess import FEATURES, N_LANDMARKS

_hands = None


def _get_hands():
    global _hands
    if _hands is None:
        import mediapipe as mp  # imported lazily so the API works without it
        _hands = mp.solutions.hands.Hands(
            static_image_mode=False, max_num_hands=2,
            min_detection_confidence=0.6, min_tracking_confidence=0.5)
    return _hands


def extract_from_rgb(rgb_image) -> np.ndarray:
    """Return a 126-vector from an RGB uint8 image. Hands are ordered left to right."""
    res = _get_hands().process(rgb_image)
    vec = np.zeros(FEATURES, dtype=np.float32)
    if not res.multi_hand_landmarks:
        return vec
    hands = []
    for h in res.multi_hand_landmarks[:2]:
        hands.append(np.array([[p.x, p.y, p.z] for p in h.landmark], dtype=np.float32))
    hands.sort(key=lambda a: a[0, 0])  # stable slot order by wrist x
    for i, pts in enumerate(hands):
        vec[i * N_LANDMARKS * 3:(i + 1) * N_LANDMARKS * 3] = pts.reshape(-1)
    return vec


def extract_from_jpeg(data: bytes) -> np.ndarray:
    import cv2
    img = cv2.imdecode(np.frombuffer(data, np.uint8), cv2.IMREAD_COLOR)
    if img is None:
        raise ValueError("could not decode image")
    return extract_from_rgb(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))

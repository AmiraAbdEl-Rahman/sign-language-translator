"""Generate SYNTHETIC landmark data so the whole pipeline can be tested end to end.

This is NOT real sign language data. Replace it with real recordings
(collect_data.py / extract_landmarks.py) before using the model with real users.
"""
import argparse
import os
import numpy as np
from common import load_words, ROOT, SEQ_LEN

# finger extension per word: thumb, index, middle, ring, pinky (0.3 = curled, 1 = straight)
POSES = {
    "Hello": ([1, 1, 1, 1, 1], 0.35), "Thank you": ([.5, 1, 1, 1, 1], 0.0), "Yes": ([.3, .3, .3, .3, .3], 0.12),
    "No": ([.5, 1, 1, .3, .3], 0.12), "Doctor": ([.3, 1, 1, .3, .3], 0.0), "Pain": ([.3, 1, .3, .3, .3], 0.25),
    "Help": ([1, .3, .3, .3, .3], 0.0), "Water": ([.3, 1, 1, 1, .3], 0.0),
}
FINGERS = [  # base joint index, base offset (x, y), direction in degrees, length
    (1, (-.35, .25), 140, .9), (5, (-.25, .75), 98, .9), (9, (0, .8), 90, 1.0),
    (13, (.25, .75), 82, .9), (17, (.45, .6), 70, .7)]


def hand_points(pose, angle=0.0):
    pts = np.zeros((21, 3), np.float32)
    for f, (base, off, deg, ln) in enumerate(FINGERS):
        e = pose[f]
        bx, by = off
        pts[base] = (bx, by, 0)
        a = np.radians(deg)
        for k in range(1, 4):
            pts[base + k] = (bx + np.cos(a) * ln * e * k / 3, by + np.sin(a) * ln * e * k / 3, 0.02 * k)
    c, s = np.cos(angle), np.sin(angle)
    R = np.array([[c, -s, 0], [s, c, 0], [0, 0, 1]], np.float32)
    return pts @ R.T


def make_sequence(word, rng, frames=30):
    pose, wave = POSES[word]
    pose = np.clip(np.array(pose) + rng.normal(0, 0.05, 5), 0.2, 1.1)
    base = rng.uniform(0.3, 0.7, 2)
    scale = rng.uniform(0.15, 0.3)
    seq = []
    for t in range(frames):
        ang = wave * np.sin(2 * np.pi * (t / frames) * 2 + rng.uniform(0, 0.3)) + rng.normal(0, 0.03)
        pts = hand_points(pose, ang) * scale
        pts[:, 0] += base[0] + rng.normal(0, 0.003)
        pts[:, 1] = base[1] - pts[:, 1] + rng.normal(0, 0.003)
        frame = np.zeros((2, 21, 3), np.float32)
        frame[0] = pts + rng.normal(0, 0.002, pts.shape)
        seq.append(frame.reshape(-1))
    return np.stack(seq)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(ROOT, "data", "demo"))
    ap.add_argument("--per-word", type=int, default=80)
    ap.add_argument("--seed", type=int, default=7)
    a = ap.parse_args()
    rng = np.random.default_rng(a.seed)
    for w in load_words():
        os.makedirs(os.path.join(a.out, w), exist_ok=True)
        for i in range(a.per_word):
            np.save(os.path.join(a.out, w, f"{i:04d}.npy"), make_sequence(w, rng, SEQ_LEN))
    print("wrote synthetic dataset to", a.out)

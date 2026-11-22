"""Convert recorded videos into landmark sequences.

Layout in:  <videos>/<Word>/*.mp4      Layout out: <out>/<Word>/*.npy
Usage: python ml/extract_landmarks.py --videos data/videos --out data/raw
"""
import argparse
import os
import cv2
import numpy as np
from common import ROOT, load_words
from backend.landmarks import extract_from_rgb


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--videos", default=os.path.join(ROOT, "data", "videos"))
    ap.add_argument("--out", default=os.path.join(ROOT, "data", "raw"))
    a = ap.parse_args()
    for w in load_words():
        src = os.path.join(a.videos, w)
        if not os.path.isdir(src):
            print("skip (no folder):", w)
            continue
        dst = os.path.join(a.out, w)
        os.makedirs(dst, exist_ok=True)
        for fn in sorted(os.listdir(src)):
            cap = cv2.VideoCapture(os.path.join(src, fn))
            frames = []
            while True:
                ok, f = cap.read()
                if not ok:
                    break
                frames.append(extract_from_rgb(cv2.cvtColor(f, cv2.COLOR_BGR2RGB)))
            cap.release()
            if frames and np.any(np.stack(frames)):
                np.save(os.path.join(dst, os.path.splitext(fn)[0] + ".npy"), np.stack(frames))
                print("saved", w, fn, len(frames), "frames")


if __name__ == "__main__":
    main()

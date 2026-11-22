"""Record real sign samples with a webcam.

Usage: python ml/collect_data.py --word Hello --count 50
Press SPACE to record one 30-frame sample, Q to quit.
"""
import argparse
import os
import cv2
import numpy as np
from common import ROOT, SEQ_LEN
from backend.landmarks import extract_from_rgb


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--word", required=True)
    ap.add_argument("--count", type=int, default=50)
    ap.add_argument("--out", default=os.path.join(ROOT, "data", "raw"))
    a = ap.parse_args()
    folder = os.path.join(a.out, a.word)
    os.makedirs(folder, exist_ok=True)
    n = len([f for f in os.listdir(folder) if f.endswith(".npy")])
    cap = cv2.VideoCapture(0)
    while n < a.count:
        ok, frame = cap.read()
        if not ok:
            break
        cv2.putText(frame, f"{a.word}: {n}/{a.count}  SPACE=record  Q=quit", (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
        cv2.imshow("collect", frame)
        k = cv2.waitKey(1) & 0xFF
        if k == ord("q"):
            break
        if k == ord(" "):
            seq = []
            while len(seq) < SEQ_LEN:
                ok, f = cap.read()
                if not ok:
                    break
                seq.append(extract_from_rgb(cv2.cvtColor(f, cv2.COLOR_BGR2RGB)))
                cv2.imshow("collect", f)
                cv2.waitKey(1)
            if len(seq) == SEQ_LEN and np.any(np.stack(seq)):
                np.save(os.path.join(folder, f"{n:04d}.npy"), np.stack(seq))
                n += 1
    cap.release()
    cv2.destroyAllWindows()


if __name__ == "__main__":
    main()

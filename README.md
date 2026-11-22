# Sign Language Translator

Mobile app (Flutter) + API (Flask) + AI model (LSTM on MediaPipe hand landmarks) that translates sign
language into text and speech.

    sign_language_translator/
    ├── backend/      Flask API, pre-processing, predictor, SQLite
    ├── ml/           data collection, training, evaluation, TFLite export
    ├── mobile_app/   Flutter app (lib/, test/, pubspec.yaml)
    ├── models/       trained model (a DEMO model trained on synthetic data is included)
    ├── tests/        pytest tests for the backend
    └── reports/      evaluation output (confusion matrix, classification report)

## IMPORTANT: the included model is a demo
`models/sign_model.keras` was trained on **synthetic** landmark data (`ml/make_demo_data.py`) only to prove
that the pipeline works end to end. Its ~100% accuracy means nothing about real sign language.
Collect real recordings and retrain before using it with real users (steps below).

## 1. Run the backend

    python -m venv .venv && source .venv/bin/activate
    pip install -r backend/requirements.txt
    python -m backend.app                  # http://0.0.0.0:5000
    # production: gunicorn -w 2 -b 0.0.0.0:5000 "backend.app:create_app()"

Endpoints: `GET /api/health`, `GET /api/signs`, `POST /api/predict` (landmark frames),
`POST /api/predict_images` (base64 JPEG frames, needs mediapipe + opencv), `GET|DELETE /api/history`.
The recognition threshold defaults to 0.8 (`THRESHOLD=0.85 python -m backend.app` to change it).

## 2. Collect real data and train

    python ml/collect_data.py --word Hello --count 50      # webcam, SPACE records one sample
    #   or convert videos:  python ml/extract_landmarks.py --videos data/videos --out data/raw
    python ml/train.py --data data/raw                      # 70/15/15 split, LSTM, early stopping
    python ml/evaluate.py                                   # report + confusion matrix in reports/
    python ml/export_tflite.py                              # optional, for on-device use later

Edit `backend/data/vocabulary.json` to change the vocabulary (retrain afterwards).
Record 50-100 samples per word from different people, lighting and backgrounds.

## 3. Run the mobile app
See `mobile_app/android_notes/SETUP.md` for platform setup, then:

    cd mobile_app && flutter pub get && flutter run

The app captures camera frames, sends them to `/api/predict_images`, and shows/speaks the result.
**The Flutter code was written but not compiled or run in the environment that generated it**;
expect to fix small issues on the first `flutter analyze` / `flutter run`.

## 4. Tests

    python -m pytest -q                 # backend (15 tests)
    cd mobile_app && flutter test       # model tests
CI is defined in `.github/workflows/ci.yml`.

## Known limitations
- Vocabulary of 8 words; no sentences or sign grammar.
- Frames are processed on the server (needs a network connection); on-device inference is future work.
- Real-world accuracy has not been measured because no real dataset was available.

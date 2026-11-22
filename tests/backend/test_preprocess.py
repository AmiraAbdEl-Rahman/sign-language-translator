import numpy as np
import pytest
from backend.preprocess import build_sequence, normalize_frame, SEQ_LEN, FEATURES


def frame(offset=0.0, scale=1.0):
    pts = np.random.default_rng(1).random((21, 3)).astype(np.float32) * scale + offset
    out = np.zeros((2, 21, 3), np.float32)
    out[0] = pts
    return out.reshape(-1)


def test_normalize_is_translation_and_scale_invariant():
    a = normalize_frame(frame())
    b = normalize_frame(frame(offset=0.4, scale=1.0))
    assert np.allclose(a, b, atol=1e-5)


def test_missing_hand_stays_zero():
    n = normalize_frame(frame()).reshape(2, 21, 3)
    assert not n[1].any()


def test_long_input_is_resampled():
    assert build_sequence([frame()] * 100).shape == (SEQ_LEN, FEATURES)


def test_short_input_is_padded():
    assert build_sequence([frame()] * 5).shape == (SEQ_LEN, FEATURES)


@pytest.mark.parametrize("bad", [[], [[1, 2, 3]], [[0.0] * 10]])
def test_invalid_input_raises(bad):
    with pytest.raises(ValueError):
        build_sequence(bad)

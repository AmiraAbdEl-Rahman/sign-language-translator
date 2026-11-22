FRAMES = [[0.1] * 126] * 30


def test_health(client):
    r = client.get("/api/health")
    assert r.status_code == 200 and r.json["status"] == "ok"


def test_signs_lists_vocabulary(client):
    r = client.get("/api/signs")
    assert r.status_code == 200 and len(r.json) == 8
    assert {"id", "label_en", "label_ar", "category"} <= set(r.json[0])


def test_predict_success_and_history(client):
    r = client.post("/api/predict", json={"frames": FRAMES})
    assert r.status_code == 200
    assert r.json["recognized"] and r.json["label"] == "Hello"
    h = client.get("/api/history").json
    assert len(h) == 1 and h[0]["label_en"] == "Hello"


def test_low_confidence_not_recognized_and_not_saved(low_conf_client):
    r = low_conf_client.post("/api/predict", json={"frames": FRAMES})
    assert r.json["label"] is None and r.json["recognized"] is False
    assert low_conf_client.get("/api/history").json == []


def test_predict_rejects_bad_payloads(client):
    assert client.post("/api/predict", json={}).status_code == 400
    assert client.post("/api/predict", json={"frames": [[1, 2]]}).status_code == 400
    assert client.post("/api/predict", data="nope").status_code == 400


def test_clear_history(client):
    client.post("/api/predict", json={"frames": FRAMES})
    assert client.delete("/api/history").json["cleared"] is True
    assert client.get("/api/history").json == []

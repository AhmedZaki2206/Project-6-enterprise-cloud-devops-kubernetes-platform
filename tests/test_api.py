from fastapi.testclient import TestClient

from app.main import APP_VERSION, app

client = TestClient(app)


def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["service"] == "Infrastructure Operations API"


def test_health_endpoints():
    assert client.get("/health/live").json() == {"status": "alive"}
    assert client.get("/health/ready").json() == {"status": "ready"}


def test_version():
    assert client.get("/version").json() == {"version": APP_VERSION}


def test_server_collection_and_item():
    assert len(client.get("/api/servers").json()) == 3
    assert client.get("/api/servers/1").json()["hostname"] == "demo-web-01"


def test_missing_server_returns_meaningful_error():
    response = client.get("/api/servers/999")
    assert response.status_code == 404
    assert "not found" in response.json()["detail"]


def test_server_id_validation():
    assert client.get("/api/servers/0").status_code == 422
    assert client.get("/api/servers/not-a-number").status_code == 422

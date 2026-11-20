import json
import logging
import os
import sys
from datetime import datetime, timezone

from fastapi import FastAPI, HTTPException, Path, Request
from pydantic import BaseModel, ConfigDict


class JsonFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        return json.dumps({
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
        })


handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(JsonFormatter())
logger = logging.getLogger("infrastructure-operations-api")
logger.handlers = [handler]
logger.setLevel(os.getenv("LOG_LEVEL", "INFO").upper())
logger.propagate = False

APP_VERSION = os.getenv("APP_VERSION", "0.1.0-dev")
ENVIRONMENT = os.getenv("APP_ENV", "local")


class Server(BaseModel):
    model_config = ConfigDict(frozen=True)
    id: int
    hostname: str
    environment: str
    status: str
    region: str


SERVERS = (
    Server(id=1, hostname="demo-web-01", environment="development", status="online", region="eu-central-1"),
    Server(id=2, hostname="demo-api-01", environment="staging", status="maintenance", region="eu-central-1"),
    Server(id=3, hostname="demo-worker-01", environment="development", status="online", region="local-kind"),
)

app = FastAPI(title="Infrastructure Operations API", version=APP_VERSION)


@app.middleware("http")
async def request_logging(request: Request, call_next):
    response = await call_next(request)
    logger.info("request method=%s path=%s status=%s", request.method, request.url.path, response.status_code)
    return response


@app.get("/")
def root() -> dict[str, str]:
    return {"service": "Infrastructure Operations API", "environment": ENVIRONMENT, "status": "running"}


@app.get("/health/live")
def live() -> dict[str, str]:
    return {"status": "alive"}


@app.get("/health/ready")
def ready() -> dict[str, str]:
    return {"status": "ready"}


@app.get("/version")
def version() -> dict[str, str]:
    return {"version": APP_VERSION}


@app.get("/api/servers", response_model=list[Server])
def list_servers() -> tuple[Server, ...]:
    return SERVERS


@app.get("/api/servers/{server_id}", response_model=Server)
def get_server(server_id: int = Path(ge=1)) -> Server:
    server = next((item for item in SERVERS if item.id == server_id), None)
    if server is None:
        raise HTTPException(status_code=404, detail=f"Fictional server {server_id} was not found")
    return server

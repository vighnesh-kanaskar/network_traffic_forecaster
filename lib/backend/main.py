from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from database import initialize_database
from network_monitor import monitor
from services.history_worker import start_history_worker

from api import dashboard
from api import traffic
from api import forecast
from api import alerts
from api import history


@asynccontextmanager
async def lifespan(app: FastAPI):

    print("----------------------------------------")
    print(" NETRA Network Intelligence")
    print("----------------------------------------")

    print("Initializing database...")

    initialize_database()

    print("Starting real network monitor...")

    monitor.start()

    start_history_worker()

    yield

    print("Stopping network monitor...")

    monitor.stop()


app = FastAPI(
    title="NETRA Network Intelligence",
    lifespan=lifespan
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(
    dashboard.router,
    prefix="/api"
)

app.include_router(
    traffic.router,
    prefix="/api"
)

app.include_router(
    forecast.router,
    prefix="/api"
)

app.include_router(
    alerts.router,
    prefix="/api"
)

app.include_router(
    history.router,
    prefix="/api"
)


@app.get("/")
def root():

    return {
        "application": "NETRA",
        "status": "online",
        "monitoring": monitor.running
    }
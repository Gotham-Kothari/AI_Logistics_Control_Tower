from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import get_settings
from app.core.logging import setup_logging
from app.db.session import Base, engine
from app.routers.alerts import router as alerts_router
from app.routers.decisions import router as decisions_router
from app.routers.events import router as events_router
from app.routers.recommendations import router as recommendations_router
from app.routers.shipments import router as shipments_router
from app.routers.status import router as status_router

settings = get_settings()
setup_logging()

app = FastAPI(title=settings.app_name, debug=settings.debug)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allow_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

api_prefix = settings.api_prefix

app.include_router(status_router, prefix=api_prefix)
app.include_router(shipments_router, prefix=api_prefix)
app.include_router(alerts_router, prefix=api_prefix)
app.include_router(events_router, prefix=api_prefix)
app.include_router(decisions_router, prefix=api_prefix)
app.include_router(recommendations_router, prefix=api_prefix)


@app.on_event("startup")
def startup():
    Base.metadata.create_all(bind=engine)
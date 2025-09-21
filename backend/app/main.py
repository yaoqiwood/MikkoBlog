from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.db.session import initialize_database
from app.api.routers.health import router as health_router
from app.api.routers.posts import router as posts_router
from app.api.routers.auth import router as auth_router
from app.api.routers.admin import router as admin_router


def create_app() -> FastAPI:
    app = FastAPI(title="MikkoBlog API", version="0.1.0")

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_allow_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    initialize_database()

    app.include_router(health_router, prefix="/api")
    app.include_router(posts_router, prefix="/api")
    app.include_router(auth_router, prefix="/api")
    app.include_router(admin_router, prefix="/api")

    return app


app = create_app()




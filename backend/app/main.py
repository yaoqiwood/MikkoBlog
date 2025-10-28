from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.core.config import settings
from app.db.session import initialize_database
from app.api.routers.health import router as health_router
from app.api.routers.posts import router as posts_router
from app.api.routers.auth import router as auth_router
from app.api.routers.admin import router as admin_router
from app.api.routers.upload import router as upload_router
from app.api.routers.comments import router as comments_router
from app.api.routers.system import router as system_router
from app.api.routers.attachments import router as attachments_router
from app.api.routers.homepage import router as homepage_router
from app.api.routers.postStats import router as post_stats_router
from app.api.routers.stats import router as stats_router
from app.api.routers.moments import router as moments_router
from app.api.routers.columns import router as columns_router
from app.api.routers.image_search import router as image_search_router
from app.api.routers.tagCloud import router as tag_cloud_router
from app.api.routers.system_setting import router as system_setting_router
from app.api.routers.local_music import router as local_music_router
from app.scheduler.tag_cloud_scheduler import (
    start_tag_cloud_scheduler,
    stop_tag_cloud_scheduler
)

# 导入模型以确保SQLModel能够识别并创建表
from app.models.postLikeTracking import PostLikeTracking  # noqa: F401
from app.models.comment import Comment  # noqa: F401


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
    app.include_router(upload_router, prefix="/api")
    app.include_router(comments_router, prefix="/api")
    app.include_router(system_router, prefix="/api")
    app.include_router(attachments_router, prefix="/api")
    app.include_router(homepage_router, prefix="/api")
    app.include_router(post_stats_router, prefix="/api")
    app.include_router(stats_router, prefix="/api")
    app.include_router(moments_router, prefix="/api")
    app.include_router(columns_router, prefix="/api/columns", tags=["columns"])
    app.include_router(
        image_search_router,
        prefix="/api/image-search",
        tags=["image-search"]
    )
    app.include_router(
        tag_cloud_router,
        prefix="/api/tag-cloud",
        tags=["tag-cloud"]
    )
    app.include_router(
        system_setting_router,
        prefix="/api/system-setting",
        tags=["system-setting"]
    )

    # 导入音乐相关路由
    from app.api.routers.music import router as music_router

    app.include_router(
        music_router,
        prefix="/api/music",
        tags=["music"]
    )

    app.include_router(
        local_music_router,
        prefix="/api/local-music",
        tags=["local-music"]
    )

    # 静态文件服务
    import os
    uploads_dir = os.path.join(os.getcwd(), "uploads")
    if os.path.exists(uploads_dir):
        app.mount(
            "/uploads", StaticFiles(directory=uploads_dir), name="uploads"
        )

    # 启动定时任务
    @app.on_event("startup")
    async def startup_event():
        initialize_database()
        start_tag_cloud_scheduler()

    @app.on_event("shutdown")
    async def shutdown_event():
        stop_tag_cloud_scheduler()

    return app


app = create_app()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

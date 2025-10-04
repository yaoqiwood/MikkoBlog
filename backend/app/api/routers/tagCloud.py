from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlmodel import Session, select
from typing import List, Optional
from app.db.session import get_session
from app.models.tagCloud import (
    TagCloud, TagCloudCreate, TagCloudUpdate, TagCloudRead,
    TagCloudFetchHistoryRead
)
from app.services.tagCloud import TagCloudService
from app.scheduler.tag_cloud_scheduler import (
    update_schedule_time, get_schedule_time, get_next_run_time,
    update_schedule_config, get_schedule_config, update_search_keywords
)
from app.api.routers.auth import get_current_admin
from app.models.user import User
import logging

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get("/tags", response_model=List[TagCloudRead])
async def getTags(
    limit: int = 50,
    category: Optional[str] = None,
    isActive: Optional[bool] = True,
    session: Session = Depends(get_session)
):
    """获取标签云列表"""
    if category and isActive is not None:
        statement = (
            select(TagCloud)
            .where(
                TagCloud.category == category,
                TagCloud.is_active == isActive
            )
            .order_by(TagCloud.count.desc())
            .limit(limit)
        )
    elif category:
        statement = (
            select(TagCloud)
            .where(TagCloud.category == category)
            .order_by(TagCloud.count.desc())
            .limit(limit)
        )
    elif isActive is not None:
        statement = (
            select(TagCloud)
            .where(TagCloud.is_active == isActive)
            .order_by(TagCloud.count.desc())
            .limit(limit)
        )
    else:
        statement = (
            select(TagCloud)
            .order_by(TagCloud.count.desc())
            .limit(limit)
        )

    tags = session.exec(statement).all()
    return tags


@router.get("/tags/active", response_model=List[TagCloudRead])
async def getActiveTags(
    limit: int = 50,
    session: Session = Depends(get_session)
):
    """获取活跃标签（用于前端显示）"""
    statement = (
        select(TagCloud)
        .where(TagCloud.is_active.is_(True))
        .order_by(TagCloud.count.desc())
        .limit(limit)
    )
    tags = session.exec(statement).all()
    return tags


@router.post("/tags", response_model=TagCloudRead)
async def createTag(
    tagData: TagCloudCreate,
    currentUser: User = Depends(get_current_admin),
    session: Session = Depends(get_session)
):
    """创建标签（管理员）"""
    tagService = TagCloudService()
    tag = tagService.create_manual_tag(tagData)
    return tag


@router.put("/tags/{tagId}", response_model=TagCloudRead)
async def updateTag(
    tagId: int,
    tagData: TagCloudUpdate,
    currentUser: User = Depends(get_current_admin),
    session: Session = Depends(get_session)
):
    """更新标签（管理员）"""
    tagService = TagCloudService()
    tag = tagService.update_manual_tag(tagId, tagData)

    if not tag:
        raise HTTPException(status_code=404, detail="标签不存在")

    return tag


@router.delete("/tags/{tagId}")
async def deleteTag(
    tagId: int,
    currentUser: User = Depends(get_current_admin),
    session: Session = Depends(get_session)
):
    """删除标签（管理员）"""
    tagService = TagCloudService()
    success = tagService.delete_tag(tagId)

    if not success:
        raise HTTPException(status_code=404, detail="标签不存在")

    return {"message": "标签删除成功"}


@router.patch("/tags/{tagId}/toggle")
async def toggleTagStatus(
    tagId: int,
    currentUser: User = Depends(get_current_admin),
    session: Session = Depends(get_session)
):
    """切换标签状态（管理员）"""
    tagService = TagCloudService()
    tag = tagService.toggle_tag_status(tagId)

    if not tag:
        raise HTTPException(status_code=404, detail="标签不存在")

    return {"message": f"标签已{'激活' if tag.is_active else '禁用'}"}


@router.post("/tags/fetch")
async def fetchTagsNow(
    backgroundTasks: BackgroundTasks,
    currentUser: User = Depends(get_current_admin),
    session: Session = Depends(get_session)
):
    """立即获取标签（管理员）"""
    tagService = TagCloudService()

    # 在后台任务中执行获取
    backgroundTasks.add_task(tagService.fetch_and_update_tags)

    return {"message": "标签获取任务已启动"}


@router.get(
    "/tags/fetch-history",
    response_model=List[TagCloudFetchHistoryRead]
)
async def getFetchHistory(
    limit: int = 30,
    currentUser: User = Depends(get_current_admin),
    session: Session = Depends(get_session)
):
    """获取标签获取历史（管理员）"""
    tagService = TagCloudService()
    history = tagService.get_fetch_history(limit)
    return history


@router.get("/tags/stats")
async def getTagStats(
    currentUser: User = Depends(get_current_admin),
    session: Session = Depends(get_session)
):
    """获取标签统计信息（管理员）"""
    from sqlmodel import select, func

    # 总标签数
    totalTags = session.exec(select(func.count(TagCloud.id))).first()

    # 活跃标签数
    activeTags = session.exec(
        select(func.count(TagCloud.id)).where(TagCloud.is_active.is_(True))
    ).first()

    # 按分类统计
    categoryStats = session.exec(
        select(TagCloud.category, func.count(TagCloud.id))
        .group_by(TagCloud.category)
        .order_by(func.count(TagCloud.id).desc())
    ).all()

    # 按来源统计
    sourceStats = session.exec(
        select(TagCloud.source, func.count(TagCloud.id))
        .group_by(TagCloud.source)
        .order_by(func.count(TagCloud.id).desc())
    ).all()

    return {
        "total_tags": totalTags,
        "active_tags": activeTags,
        "category_stats": [
            {"category": cat, "count": count}
            for cat, count in categoryStats
        ],
        "source_stats": [
            {"source": src, "count": count}
            for src, count in sourceStats
        ]
    }


@router.get("/schedule/time")
async def getScheduleTime():
    """获取当前调度时间"""
    current_time = get_schedule_time()
    next_run = get_next_run_time()
    return {
        "current_time": current_time,
        "next_run": next_run.isoformat() if next_run else None
    }


@router.get("/schedule/config")
async def getScheduleConfig():
    """获取当前调度配置"""
    config = get_schedule_config()
    next_run = get_next_run_time()
    return {
        "frequency": config["frequency"],
        "time": config["time"],
        "day": config["day"],
        "search_keywords": config["search_keywords"],
        "next_run": next_run.isoformat() if next_run else None
    }


@router.put("/schedule/time")
async def updateScheduleTime(
    time_data: dict,
    currentUser: User = Depends(get_current_admin)
):
    """更新调度时间"""
    new_time = time_data.get("time")
    if not new_time:
        raise HTTPException(status_code=400, detail="时间参数不能为空")

    # 验证时间格式 (HH:MM)
    try:
        from datetime import datetime
        datetime.strptime(new_time, "%H:%M")
    except ValueError:
        raise HTTPException(status_code=400, detail="时间格式错误，请使用 HH:MM 格式")

    update_schedule_time(new_time)
    return {"message": f"调度时间已更新为 {new_time}"}


@router.put("/schedule/config")
async def updateScheduleConfig(
    config_data: dict,
    currentUser: User = Depends(get_current_admin)
):
    """更新调度配置"""
    frequency = config_data.get("frequency")
    time_str = config_data.get("time")
    day = config_data.get("day")

    # 验证频度
    valid_frequencies = ["hourly", "daily", "weekly"]
    if frequency and frequency not in valid_frequencies:
        raise HTTPException(status_code=400, detail=f"频度必须是以下之一: {', '.join(valid_frequencies)}")

    # 验证时间格式
    if time_str:
        try:
            from datetime import datetime
            datetime.strptime(time_str, "%H:%M")
        except ValueError:
            raise HTTPException(status_code=400, detail="时间格式错误，请使用 HH:MM 格式")

    # 验证星期几
    valid_days = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
    if day and day.lower() not in valid_days:
        raise HTTPException(status_code=400, detail=f"星期几必须是以下之一: {', '.join(valid_days)}")

    update_schedule_config(frequency, time_str, day)
    return {"message": "调度配置已更新"}


@router.put("/search/keywords")
async def updateSearchKeywords(
    keywords_data: dict,
    currentUser: User = Depends(get_current_admin)
):
    """更新搜索关键词"""
    keywords = keywords_data.get("keywords")

    if not keywords:
        raise HTTPException(status_code=400, detail="关键词不能为空")

    # 确保关键词是列表格式
    if isinstance(keywords, str):
        keywords = [keyword.strip() for keyword in keywords.split(",") if keyword.strip()]
    elif not isinstance(keywords, list):
        raise HTTPException(status_code=400, detail="关键词必须是字符串或列表格式")

    # 验证关键词数量
    if len(keywords) > 10:
        raise HTTPException(status_code=400, detail="关键词数量不能超过10个")

    # 验证关键词长度
    for keyword in keywords:
        if len(keyword) > 50:
            raise HTTPException(status_code=400, detail="单个关键词长度不能超过50个字符")

    update_search_keywords(keywords)
    return {"message": f"搜索关键词已更新: {', '.join(keywords)}"}


@router.post("/search/fetch")
async def fetchTagsByKeywords(
    keywords_data: dict,
    currentUser: User = Depends(get_current_admin),
    backgroundTasks: BackgroundTasks = BackgroundTasks()
):
    """立即根据关键词获取标签"""
    keywords = keywords_data.get("keywords")

    if not keywords:
        raise HTTPException(status_code=400, detail="关键词不能为空")

    # 确保关键词是列表格式
    if isinstance(keywords, str):
        keywords = [keyword.strip() for keyword in keywords.split(",") if keyword.strip()]
    elif not isinstance(keywords, list):
        raise HTTPException(status_code=400, detail="关键词必须是字符串或列表格式")

    # 验证关键词数量
    if len(keywords) > 10:
        raise HTTPException(status_code=400, detail="关键词数量不能超过10个")

    # 异步执行搜索任务
    backgroundTasks.add_task(fetch_tags_by_keywords_task, keywords)

    return {"message": f"关键词搜索任务已启动: {', '.join(keywords)}"}


async def fetch_tags_by_keywords_task(keywords):
    """后台任务：根据关键词获取标签"""
    try:
        with next(get_session()) as session:
            tag_service = TagCloudService(session)
            result = await tag_service.fetch_tags_by_keywords(keywords)
            logger.info(f"Keywords fetch task completed: {result}")
    except Exception as e:
        logger.error(f"Keywords fetch task failed: {e}", exc_info=True)

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


@router.get("/tags")
async def getTags(
    page: int = 1,
    page_size: int = 10,
    limit: Optional[int] = None,
    category: Optional[str] = None,
    isActive: Optional[bool] = None,
    source: Optional[str] = None,
    session: Session = Depends(get_session)
):
    """获取标签云列表（支持分页）"""
    from sqlmodel import func

    # 构建基础查询条件
    conditions = []
    if category:
        conditions.append(TagCloud.category == category)
    if isActive is not None:
        conditions.append(TagCloud.is_active == isActive)
    if source:
        conditions.append(TagCloud.source == source)

    # 构建查询语句
    base_statement = select(TagCloud)
    if conditions:
        base_statement = base_statement.where(*conditions)

    # 获取总数
    count_statement = select(func.count(TagCloud.id))
    if conditions:
        count_statement = count_statement.where(*conditions)
    total = session.exec(count_statement).first() or 0

    # 构建分页查询
    offset = (page - 1) * page_size
    statement = (
        base_statement
        .order_by(TagCloud.count.desc())
        .offset(offset)
        .limit(page_size)
    )

    # 如果指定了limit，使用limit而不是page_size
    if limit is not None:
        statement = base_statement.order_by(TagCloud.count.desc()).limit(limit)
        total = min(total, limit)

    tags = session.exec(statement).all()

    return {
        "items": tags,
        "total": total,
        "page": page,
        "page_size": page_size,
        "total_pages": (
            (total + page_size - 1) // page_size
            if page_size > 0 else 0
        )
    }


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
    tagService = TagCloudService(session)

    # 创建同步包装器来处理异步任务
    def sync_fetch_task():
        import asyncio
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        try:
            return loop.run_until_complete(tagService.fetch_and_update_tags())
        finally:
            loop.close()

    # 在后台任务中执行获取
    backgroundTasks.add_task(sync_fetch_task)

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

    # 从系统设置中获取搜索关键词和提示词模板
    search_keywords = config.get("search_keywords", [])
    prompt_template = config.get("prompt_template")

    try:
        from app.db.session import get_session
        from app.models.system_setting import SystemSetting
        from sqlmodel import select
        import json

        session = next(get_session())

        # 获取搜索关键词
        statement = select(SystemSetting).where(
            SystemSetting.category == "ai",
            SystemSetting.key_name == "search_keywords"
        )
        keywords_setting = session.exec(statement).first()
        if keywords_setting and keywords_setting.key_value:
            try:
                search_keywords = json.loads(keywords_setting.key_value)
            except json.JSONDecodeError:
                logger.warning("搜索关键词JSON解析失败，使用默认值")

        # 获取提示词模板
        statement = select(SystemSetting).where(
            SystemSetting.category == "ai",
            SystemSetting.key_name == "prompt_template"
        )
        prompt_setting = session.exec(statement).first()
        if prompt_setting and prompt_setting.key_value:
            prompt_template = prompt_setting.key_value

        session.close()
    except Exception as e:
        logger.error(f"获取系统设置失败: {e}")

    return {
        "frequency": config["frequency"],
        "time": config["time"],
        "day": config["day"],
        "search_keywords": search_keywords,
        "prompt_template": prompt_template,
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
        raise HTTPException(
            status_code=400,
            detail=f"频度必须是以下之一: {', '.join(valid_frequencies)}"
        )

    # 验证时间格式
    if time_str:
        try:
            from datetime import datetime
            datetime.strptime(time_str, "%H:%M")
        except ValueError:
            raise HTTPException(status_code=400, detail="时间格式错误，请使用 HH:MM 格式")

    # 验证星期几
    valid_days = [
        "monday", "tuesday", "wednesday", "thursday",
        "friday", "saturday", "sunday"
    ]
    if day and day.lower() not in valid_days:
        raise HTTPException(
            status_code=400,
            detail=f"星期几必须是以下之一: {', '.join(valid_days)}"
        )

    update_schedule_config(frequency, time_str, day)
    return {"message": "调度配置已更新"}


@router.put("/search/keywords")
async def updateSearchKeywords(
    keywords_data: dict,
    currentUser: User = Depends(get_current_admin)
):
    """更新搜索关键词和提示词模板"""
    keywords = keywords_data.get("keywords")
    prompt_template = keywords_data.get("prompt_template")

    if not keywords:
        raise HTTPException(status_code=400, detail="关键词不能为空")

    # 确保关键词是列表格式
    if isinstance(keywords, str):
        # 支持中文逗号和英文逗号混写
        import re
        keywords = [
            keyword.strip()
            for keyword in re.split(r'[,，]', keywords)
            if keyword.strip()
        ]
    elif not isinstance(keywords, list):
        raise HTTPException(status_code=400, detail="关键词必须是字符串或列表格式")

    # 验证关键词数量
    if len(keywords) > 10:
        raise HTTPException(status_code=400, detail="关键词数量不能超过10个")

    # 验证关键词长度
    for keyword in keywords:
        if len(keyword) > 50:
            raise HTTPException(status_code=400, detail="单个关键词长度不能超过50个字符")

    # 验证提示词模板
    if prompt_template and len(prompt_template) > 1000:
        raise HTTPException(status_code=400, detail="提示词模板长度不能超过1000个字符")

    # 更新调度器中的搜索关键词和提示词模板
    update_search_keywords(keywords, prompt_template)

    # 同时更新系统设置
    try:
        from app.db.session import get_session
        from app.models.system_setting import SystemSetting
        from sqlmodel import select
        import json

        session = next(get_session())

        # 更新搜索关键词到系统设置
        keywords_json = json.dumps(keywords, ensure_ascii=False)
        statement = select(SystemSetting).where(
            SystemSetting.category == "ai",
            SystemSetting.key_name == "search_keywords"
        )
        keywords_setting = session.exec(statement).first()

        if not keywords_setting:
            # 创建新的搜索关键词设置项
            keywords_setting = SystemSetting(
                category="ai",
                key_name="search_keywords",
                key_value=keywords_json,
                key_type="json",
                description="AI搜索关键词",
                is_editable=True,
                is_public=False,
                sort_order=1
            )
            session.add(keywords_setting)
        else:
            # 更新现有设置
            keywords_setting.key_value = keywords_json
            session.add(keywords_setting)

        # 如果提供了提示词模板，也更新到系统设置
        if prompt_template:
            statement = select(SystemSetting).where(
                SystemSetting.category == "ai",
                SystemSetting.key_name == "prompt_template"
            )
            prompt_setting = session.exec(statement).first()

            if not prompt_setting:
                # 创建新的提示词模板设置项
                prompt_setting = SystemSetting(
                    category="ai",
                    key_name="prompt_template",
                    key_value=prompt_template,
                    key_type="string",
                    description="AI提示词模板",
                    is_editable=True,
                    is_public=False,
                    sort_order=0
                )
                session.add(prompt_setting)
            else:
                # 更新现有设置
                prompt_setting.key_value = prompt_template
                session.add(prompt_setting)

        session.commit()
        session.close()
        logger.info("系统设置中的搜索关键词和提示词模板已更新")

    except Exception as e:
        logger.error(f"更新系统设置失败: {e}")
        # 不抛出异常，因为调度器更新已经成功

    return {"message": f"搜索关键词和提示词模板已更新: {', '.join(keywords)}"}


@router.post("/search/fetch")
async def fetchTagsByKeywords(
    keywords_data: dict,
    currentUser: User = Depends(get_current_admin),
    backgroundTasks: BackgroundTasks = BackgroundTasks()
):
    """立即根据关键词获取标签"""
    keywords = keywords_data.get("keywords")
    prompt_template = keywords_data.get("prompt_template")

    if not keywords:
        raise HTTPException(status_code=400, detail="关键词不能为空")

    # 确保关键词是列表格式
    if isinstance(keywords, str):
        # 支持中文逗号和英文逗号混写
        import re
        keywords = [
            keyword.strip()
            for keyword in re.split(r'[,，]', keywords)
            if keyword.strip()
        ]
    elif not isinstance(keywords, list):
        raise HTTPException(status_code=400, detail="关键词必须是字符串或列表格式")

    # 验证关键词数量
    if len(keywords) > 10:
        raise HTTPException(status_code=400, detail="关键词数量不能超过10个")

    # 异步执行搜索任务
    backgroundTasks.add_task(
        fetch_tags_by_keywords_task, keywords, prompt_template
    )

    return {"message": f"关键词搜索任务已启动: {', '.join(keywords)}"}


@router.post("/search/fetch/stream")
async def fetchTagsByKeywordsStream(
    keywords_data: dict,
    currentUser: User = Depends(get_current_admin)
):
    """流式获取标签数据"""
    keywords = keywords_data.get("keywords")
    prompt_template = keywords_data.get("prompt_template")

    # 验证关键词
    if not keywords or not isinstance(keywords, list):
        raise HTTPException(status_code=400, detail="关键词必须是列表格式")

    if len(keywords) == 0:
        raise HTTPException(status_code=400, detail="请输入至少一个关键词")

    if len(keywords) > 10:
        raise HTTPException(status_code=400, detail="关键词数量不能超过10个")

    # 验证提示词模板
    if prompt_template and len(prompt_template) > 1000:
        raise HTTPException(status_code=400, detail="提示词模板长度不能超过1000个字符")

    from fastapi.responses import StreamingResponse
    import json
    import asyncio
    from app.services.tagCloud import TagCloudService
    from app.db.session import get_session

    async def generate_stream():
        try:
            # 发送开始信号
            start_data = json.dumps(
                {'type': 'start', 'message': '开始获取标签数据...'},
                ensure_ascii=False
            )
            yield f"data: {start_data}\n\n"

            # 获取AI响应
            with next(get_session()) as session:
                tag_service = TagCloudService(session)

                # 发送AI请求开始信号
                ai_request_data = json.dumps(
                    {'type': 'ai_request', 'message': '正在向AI发送请求...'},
                    ensure_ascii=False
                )
                yield f"data: {ai_request_data}\n\n"

                # 获取AI响应（流式）
                ai_response_stream = tag_service.fetch_tags_from_ai_stream(
                    keywords, prompt_template
                )

                # 逐字发送AI响应
                full_response = ""
                async for chunk in ai_response_stream:
                    full_response += chunk
                    ai_response_data = json.dumps(
                        {'type': 'ai_response', 'content': chunk},
                        ensure_ascii=False
                    )
                    yield f"data: {ai_response_data}\n\n"
                    await asyncio.sleep(0.05)  # 控制发送速度

                # 发送解析开始信号
                parse_start_data = json.dumps(
                    {'type': 'parse_start', 'message': '正在解析AI响应...'},
                    ensure_ascii=False
                )
                yield f"data: {parse_start_data}\n\n"

                # 调试：显示原始响应内容
                logger.info(f"AI原始响应内容: {full_response[:500]}...")  # 只显示前500字符

                # 清理响应内容，尝试提取JSON
                cleaned_response = full_response.strip()

                # 尝试找到JSON数组的开始和结束
                json_start = cleaned_response.find('[')
                json_end = cleaned_response.rfind(']') + 1

                if json_start != -1 and json_end > json_start:
                    cleaned_response = cleaned_response[json_start:json_end]
                    logger.info(f"提取的JSON内容: {cleaned_response[:200]}...")
                else:
                    # 如果没有找到数组，尝试找到对象
                    json_start = cleaned_response.find('{')
                    json_end = cleaned_response.rfind('}') + 1
                    if json_start != -1 and json_end > json_start:
                        cleaned_response = cleaned_response[
                            json_start:json_end
                        ]
                        logger.info(
                            f"提取的JSON对象: {cleaned_response[:200]}..."
                        )

                # 解析JSON数据
                try:
                    parsed_data = json.loads(cleaned_response)

                    # 发送解析成功信号
                    parse_success_data = json.dumps(
                        {
                            'type': 'parse_success',
                            'data': parsed_data,
                            'message': '数据解析成功'
                        },
                        ensure_ascii=False
                    )
                    yield f"data: {parse_success_data}\n\n"

                except json.JSONDecodeError as e:
                    error_msg = (
                        f'JSON解析失败: {str(e)}。原始内容: {full_response[:200]}...'
                    )
                    logger.error(error_msg)
                    parse_error_data = json.dumps(
                        {'type': 'parse_error', 'message': error_msg},
                        ensure_ascii=False
                    )
                    yield f"data: {parse_error_data}\n\n"
                    return

                # 发送完成信号
                complete_data = json.dumps(
                    {'type': 'complete', 'message': '数据获取完成'},
                    ensure_ascii=False
                )
                yield f"data: {complete_data}\n\n"

        except Exception as e:
            error_data = json.dumps(
                {'type': 'error', 'message': f'获取失败: {str(e)}'},
                ensure_ascii=False
            )
            yield f"data: {error_data}\n\n"

    return StreamingResponse(
        generate_stream(),
        media_type="text/plain",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "Content-Type": "text/event-stream",
        }
    )


@router.post("/search/apply")
async def applyTagsData(
    tags_data: dict,
    currentUser: User = Depends(get_current_admin)
):
    """确认并应用标签数据"""
    tags = tags_data.get("tags", [])

    if not tags or not isinstance(tags, list):
        raise HTTPException(status_code=400, detail="标签数据格式错误")

    try:
        from app.services.tagCloud import TagCloudService
        from app.db.session import get_session

        session = next(get_session())
        try:
            tag_service = TagCloudService(session)

            # 先清空现有的标签数据
            logger.info("清空现有标签数据...")
            await tag_service.clear_all_tags()

            # 插入新的标签数据
            logger.info(f"插入{len(tags)}个新标签...")
            new_count, updated_count = await tag_service.update_tag_cloud(
                tags, "ai_keywords", clear_existing=True
            )

            logger.info(f"标签应用完成: 新增{new_count}个, 更新{updated_count}个")

            return {
                "message": "标签数据应用成功",
                "new_count": new_count,
                "updated_count": updated_count,
                "total_count": len(tags)
            }
        finally:
            session.close()

    except Exception as e:
        logger.error(f"应用标签数据失败: {e}")
        raise HTTPException(status_code=500, detail=f"应用标签数据失败: {str(e)}")


@router.post("/reassign-colors")
async def reassignTagColors(
    currentUser: User = Depends(get_current_admin)
):
    """重新分配所有标签的颜色"""
    try:
        from app.services.tagCloud import TagCloudService
        from app.db.session import get_session
        from sqlmodel import select

        session = next(get_session())
        try:
            tag_service = TagCloudService(session)

            # 获取所有标签
            statement = select(TagCloud)
            all_tags = session.exec(statement).all()

            updated_count = 0
            for tag in all_tags:
                # 重新分配颜色
                old_color = tag.color
                tag.color = tag_service.determine_tag_color(tag.category)
                session.add(tag)
                updated_count += 1
                logger.info(f"标签 '{tag.name}' 颜色从 {old_color} 更新为 {tag.color}")

            session.commit()

            return {
                "message": f"成功重新分配了 {updated_count} 个标签的颜色",
                "updated_count": updated_count
            }
        finally:
            session.close()

    except Exception as e:
        logger.error(f"重新分配标签颜色失败: {e}")
        raise HTTPException(status_code=500, detail=f"重新分配标签颜色失败: {str(e)}")


def fetch_tags_by_keywords_task(keywords, prompt_template=None):
    """后台任务：根据关键词获取标签"""
    try:
        import asyncio
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        try:
            with next(get_session()) as session:
                tag_service = TagCloudService(session)

                # 先清空现有的标签数据
                logger.info("清空现有标签数据...")
                loop.run_until_complete(tag_service.clear_all_tags())

                # 使用AI生成标签
                logger.info("使用AI生成新标签...")
                result = loop.run_until_complete(
                    tag_service.fetch_tags_by_keywords(
                        keywords, prompt_template
                    )
                )
                logger.info(f"Keywords fetch task completed: {result}")
        finally:
            loop.close()
    except Exception as e:
        logger.error(f"Keywords fetch task failed: {e}", exc_info=True)

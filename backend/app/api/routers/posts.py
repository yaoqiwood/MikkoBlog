from datetime import datetime
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlmodel import Session, select

from app.db.session import get_db
from app.models.post import Post, PostCreate, PostRead, PostUpdate
from app.models.user import UserProfile, UserRead
from app.models.postStats import PostStats
from app.models.columns import PostColumns
from app.api.routers.auth import get_current_user


router = APIRouter(prefix="/posts", tags=["posts"])


@router.get("/", response_model=List[PostRead])
def list_posts(
    page: int = Query(1, ge=1, description="页码"),
    limit: int = Query(10, ge=1, le=100, description="每页数量"),
    is_visible: Optional[bool] = Query(None, description="是否可见"),
    is_deleted: Optional[bool] = Query(None, description="是否已删除"),
    is_published: Optional[bool] = Query(None, description="是否已发布"),
    title: Optional[str] = Query(None, description="标题搜索关键词"),
    column_id: Optional[int] = Query(None, description="专栏ID筛选"),
    start_date: Optional[str] = Query(None, description="开始日期"),
    end_date: Optional[str] = Query(None, description="结束日期"),
    db: Session = Depends(get_db)
) -> List[PostRead]:
    """
    获取文章列表接口

    支持分页、可见性、删除状态、标题搜索、专栏筛选和日期范围筛选，返回文章及其作者信息和统计数据。

    参数:
        page (int): 页码，从1开始，默认1
        limit (int): 每页数量，默认10，最大100
        is_visible (Optional[bool]): 是否可见筛选（可选）
        is_deleted (Optional[bool]): 是否已删除筛选（可选）
        title (Optional[str]): 标题搜索关键词（可选）
        column_id (Optional[int]): 专栏ID筛选（可选）
        start_date (Optional[str]): 开始日期（可选）
        end_date (Optional[str]): 结束日期（可选）
        db (Session): 数据库会话（依赖注入）

    返回:
        List[PostRead]: 文章列表，每项包含文章、作者信息和统计数据
    """
    # 构建查询，联表获取文章、用户资料和统计数据
    statement = (
        select(Post, UserProfile, PostStats)
        .join(UserProfile, Post.user_id == UserProfile.user_id)
        .outerjoin(PostStats, Post.id == PostStats.post_id)
    )

    # 处理删除状态过滤
    if is_deleted is not None:
        statement = statement.where(Post.is_deleted == is_deleted)
    else:
        # 默认只显示未删除的文章
        statement = statement.where(Post.is_deleted.is_(False))

    # 处理可见性过滤
    if is_visible is not None:
        statement = statement.where(Post.is_visible == is_visible)

    # 处理发布状态过滤（默认仅显示已发布）
    if is_published is not None:
        statement = statement.where(Post.is_published == is_published)
    else:
        statement = statement.where(Post.is_published.is_(True))

    # 处理标题搜索
    if title:
        statement = statement.where(Post.title.contains(title))

    # 处理专栏筛选
    if column_id:
        # 通过PostColumns关联表筛选
        statement = statement.join(
            PostColumns, Post.id == PostColumns.post_id
        ).where(PostColumns.column_id == column_id)

    # 处理日期范围筛选
    if start_date:
        statement = statement.where(Post.created_at >= start_date)
    if end_date:
        statement = statement.where(Post.created_at <= end_date)

    # 按创建时间倒序排序，并分页
    statement = statement.order_by(Post.created_at.desc())
    statement = statement.offset((page - 1) * limit).limit(limit)

    # 执行查询
    results = db.exec(statement).all()

    # 构建响应数据列表
    result = []
    for post, user_profile, post_stats in results:
        # 组装包含文章、作者信息和统计数据的字典
        post_dict = {
            'id': post.id,
            'title': post.title,
            'content': post.content,
            'summary': post.summary,
            'cover_image_url': post.cover_image_url,
            'is_published': post.is_published,
            'is_deleted': post.is_deleted,
            'is_visible': post.is_visible,
            'user_id': post.user_id,
            'created_at': post.created_at,
            'updated_at': post.updated_at,
            'user_nickname': user_profile.nickname,
            'user_avatar': user_profile.avatar,
            # 统计数据，如果不存在则默认为0
            'view_count': post_stats.view_count if post_stats else 0,
            'like_count': post_stats.like_count if post_stats else 0,
            'share_count': post_stats.share_count if post_stats else 0,
            'comment_count': post_stats.comment_count if post_stats else 0
        }

        # 校验并转换为响应模型
        post_data = PostRead.model_validate(post_dict)
        result.append(post_data)

        # 打印调试信息
        print(f"Post {post.id}: user_nickname={user_profile.nickname}, "
              f"user_avatar={user_profile.avatar}, "
              f"stats={post_stats.view_count if post_stats else 0} views")

    return result


@router.post("/", response_model=PostRead, status_code=status.HTTP_201_CREATED)
def create_post(
    payload: PostCreate,
    current_user: UserRead = Depends(get_current_user),
    db: Session = Depends(get_db)
) -> PostRead:
    # 先将 payload 转为字典并注入 user_id，再进行验证
    data = payload.model_dump()
    data["user_id"] = current_user.id
    post = Post.model_validate(data)
    db.add(post)
    db.commit()
    db.refresh(post)
    return PostRead.model_validate(post)


@router.get("/popular", response_model=List[PostRead])
def get_popular_posts(
    limit: int = Query(3, ge=1, le=10, description="返回数量"),
    db: Session = Depends(get_db)
) -> List[PostRead]:
    """
    获取最受欢迎的博文（按浏览量排序）
    返回浏览量最多的博文列表
    """
    statement = (
        select(Post, UserProfile, PostStats)
        .join(UserProfile, Post.user_id == UserProfile.user_id)
        .outerjoin(PostStats, Post.id == PostStats.post_id)
        .where(Post.is_deleted.is_(False))
        .where(Post.is_visible.is_(True))
        .where(Post.is_published.is_(True))
        .order_by(PostStats.view_count.desc())
        .limit(limit)
    )

    results = db.exec(statement).all()
    result = []

    for post, user_profile, post_stats in results:
        post_dict = {
            'id': post.id,
            'title': post.title,
            'content': post.content,
            'summary': post.summary,
            'cover_image_url': post.cover_image_url,
            'is_published': post.is_published,
            'is_deleted': post.is_deleted,
            'is_visible': post.is_visible,
            'user_id': post.user_id,
            'created_at': post.created_at,
            'updated_at': post.updated_at,
            'user_nickname': user_profile.nickname,
            'user_avatar': user_profile.avatar,
            # 统计数据，如果不存在则默认为0
            'view_count': post_stats.view_count if post_stats else 0,
            'like_count': post_stats.like_count if post_stats else 0,
            'share_count': post_stats.share_count if post_stats else 0,
            'comment_count': post_stats.comment_count if post_stats else 0
        }

        post_data = PostRead.model_validate(post_dict)
        result.append(post_data)

    return result


@router.get("/{post_id}", response_model=PostRead)
def read_post(post_id: int, db: Session = Depends(get_db)) -> PostRead:
    post = db.get(Post, post_id)
    if not post or post.is_deleted:
        raise HTTPException(status_code=404, detail="Post not found")
    return PostRead.model_validate(post)


@router.put("/{post_id}", response_model=PostRead)
def update_post(
    post_id: int, payload: PostUpdate, db: Session = Depends(get_db)
) -> PostRead:
    post = db.get(Post, post_id)
    if not post or post.is_deleted:
        raise HTTPException(status_code=404, detail="Post not found")
    update_data = payload.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(post, key, value)
    post.updated_at = datetime.utcnow()
    db.add(post)
    db.commit()
    db.refresh(post)
    return PostRead.model_validate(post)


@router.delete("/{post_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_post(post_id: int, db: Session = Depends(get_db)) -> None:
    post = db.get(Post, post_id)
    if not post or post.is_deleted:
        raise HTTPException(status_code=404, detail="Post not found")

    # 软删除：设置 is_deleted = True
    post.is_deleted = True
    post.updated_at = datetime.utcnow()
    db.add(post)
    db.commit()
    return None


@router.patch("/{post_id}/toggle-visibility", response_model=PostRead)
def toggle_post_visibility(
    post_id: int, db: Session = Depends(get_db)
) -> PostRead:
    post = db.get(Post, post_id)
    if not post or post.is_deleted:
        raise HTTPException(status_code=404, detail="Post not found")

    # 切换可见性
    post.is_visible = not post.is_visible
    post.updated_at = datetime.utcnow()
    db.add(post)
    db.commit()
    db.refresh(post)
    return PostRead.model_validate(post)


@router.get("/{post_id}/related", response_model=List[PostRead])
def get_related_posts(
    post_id: int,
    limit: int = Query(5, ge=1, le=10, description="返回数量"),
    db: Session = Depends(get_db)
) -> List[PostRead]:
    """
    获取相关博文接口

    返回除当前博文外的最近发布的博文列表

    参数:
        post_id (int): 当前博文ID
        limit (int): 返回数量，默认5，最大10
        db (Session): 数据库会话

    返回:
        List[PostRead]: 相关博文列表
    """
    # 构建查询，联表获取文章、用户资料和统计数据
    statement = (
        select(Post, UserProfile, PostStats)
        .join(UserProfile, Post.user_id == UserProfile.user_id)
        .outerjoin(PostStats, Post.id == PostStats.post_id)
        .where(Post.is_deleted.is_(False))  # 只显示未删除的文章
        .where(Post.is_visible.is_(True))  # 只显示可见的文章
        .where(Post.id != post_id)  # 排除当前文章
        .order_by(Post.created_at.desc())  # 按创建时间倒序
        .limit(limit)
    )

    # 执行查询
    results = db.exec(statement).all()

    # 构建响应数据列表
    result = []
    for post, user_profile, post_stats in results:
        # 组装包含文章、作者信息和统计数据的字典
        post_dict = {
            'id': post.id,
            'title': post.title,
            'content': post.content,
            'summary': post.summary,
            'cover_image_url': post.cover_image_url,
            'is_published': post.is_published,
            'is_deleted': post.is_deleted,
            'is_visible': post.is_visible,
            'user_id': post.user_id,
            'created_at': post.created_at,
            'updated_at': post.updated_at,
            'user_nickname': user_profile.nickname,
            'user_avatar': user_profile.avatar,
            # 统计数据，如果不存在则默认为0
            'view_count': post_stats.view_count if post_stats else 0,
            'like_count': post_stats.like_count if post_stats else 0,
            'share_count': post_stats.share_count if post_stats else 0,
            'comment_count': post_stats.comment_count if post_stats else 0
        }

        # 校验并转换为响应模型
        post_data = PostRead.model_validate(post_dict)
        result.append(post_data)

    return result

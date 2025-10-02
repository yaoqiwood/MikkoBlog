from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select

from app.db.session import get_session
from app.models.postStats import (
    PostStats,
    PostStatsCreate,
    PostStatsRead,
    PostStatsUpdate,
    PostStatsIncrement
)
from app.models.post import Post

router = APIRouter()


@router.post("/post-stats", response_model=PostStatsRead)
def create_post_stats(
    *,
    session: Session = Depends(get_session),
    post_stats: PostStatsCreate
):
    """创建文章统计数据"""
    # 检查文章是否存在
    post = session.get(Post, post_stats.post_id)
    if not post:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="文章不存在"
        )

    # 检查是否已存在统计数据
    existing_stats = session.exec(
        select(PostStats).where(PostStats.post_id == post_stats.post_id)
    ).first()

    if existing_stats:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="该文章已存在统计数据"
        )

    db_post_stats = PostStats.model_validate(post_stats)
    session.add(db_post_stats)
    session.commit()
    session.refresh(db_post_stats)
    return db_post_stats


@router.get("/post-stats/{post_id}", response_model=PostStatsRead)
def get_post_stats(
    *,
    session: Session = Depends(get_session),
    post_id: int
):
    """获取指定文章的统计数据"""
    post_stats = session.exec(
        select(PostStats).where(PostStats.post_id == post_id)
    ).first()

    if not post_stats:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="未找到该文章的统计数据"
        )

    return post_stats


@router.get("/post-stats", response_model=List[PostStatsRead])
def get_all_post_stats(
    *,
    session: Session = Depends(get_session),
    skip: int = 0,
    limit: int = 100
):
    """获取所有文章的统计数据"""
    statement = select(PostStats).offset(skip).limit(limit)
    post_stats = session.exec(statement).all()
    return post_stats


@router.put("/post-stats/{post_id}", response_model=PostStatsRead)
def update_post_stats(
    *,
    session: Session = Depends(get_session),
    post_id: int,
    post_stats_update: PostStatsUpdate
):
    """更新文章统计数据"""
    post_stats = session.exec(
        select(PostStats).where(PostStats.post_id == post_id)
    ).first()

    if not post_stats:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="未找到该文章的统计数据"
        )

    post_stats_data = post_stats_update.model_dump(exclude_unset=True)
    for field, value in post_stats_data.items():
        setattr(post_stats, field, value)

    session.add(post_stats)
    session.commit()
    session.refresh(post_stats)
    return post_stats


@router.patch("/post-stats/{post_id}/increment", response_model=PostStatsRead)
def increment_post_stats(
    *,
    session: Session = Depends(get_session),
    post_id: int,
    increment_data: PostStatsIncrement
):
    """增加文章统计数据（观看、点赞、分享、评论）"""
    post_stats = session.exec(
        select(PostStats).where(PostStats.post_id == post_id)
    ).first()

    if not post_stats:
        # 如果不存在统计数据，创建一个新的
        post_stats = PostStats(post_id=post_id)
        session.add(post_stats)
        session.commit()
        session.refresh(post_stats)

    # 增加各项统计数据
    increment_dict = increment_data.model_dump(exclude_unset=True)
    for field, increment_value in increment_dict.items():
        if increment_value and increment_value > 0:
            current_value = getattr(post_stats, field, 0)
            setattr(post_stats, field, current_value + increment_value)

    session.add(post_stats)
    session.commit()
    session.refresh(post_stats)
    return post_stats


@router.post("/post-stats/{post_id}/view", response_model=PostStatsRead)
def increment_view_count(
    *,
    session: Session = Depends(get_session),
    post_id: int
):
    """增加文章观看次数"""
    increment_data = PostStatsIncrement(view_count=1)
    return increment_post_stats(
        session=session, post_id=post_id, increment_data=increment_data
    )


@router.post("/post-stats/{post_id}/like", response_model=PostStatsRead)
def increment_like_count(
    *,
    session: Session = Depends(get_session),
    post_id: int
):
    """增加文章点赞次数"""
    increment_data = PostStatsIncrement(like_count=1)
    return increment_post_stats(
        session=session, post_id=post_id, increment_data=increment_data
    )


@router.post("/post-stats/{post_id}/share", response_model=PostStatsRead)
def increment_share_count(
    *,
    session: Session = Depends(get_session),
    post_id: int
):
    """增加文章分享次数"""
    increment_data = PostStatsIncrement(share_count=1)
    return increment_post_stats(
        session=session, post_id=post_id, increment_data=increment_data
    )


@router.post("/post-stats/{post_id}/comment", response_model=PostStatsRead)
def increment_comment_count(
    *,
    session: Session = Depends(get_session),
    post_id: int
):
    """增加文章评论次数"""
    increment_data = PostStatsIncrement(comment_count=1)
    return increment_post_stats(
        session=session, post_id=post_id, increment_data=increment_data
    )


@router.delete("/post-stats/{post_id}")
def delete_post_stats(
    *,
    session: Session = Depends(get_session),
    post_id: int
):
    """删除文章统计数据"""
    post_stats = session.exec(
        select(PostStats).where(PostStats.post_id == post_id)
    ).first()

    if not post_stats:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="未找到该文章的统计数据"
        )

    session.delete(post_stats)
    session.commit()
    return {"message": "统计数据删除成功"}


@router.get("/post-stats/top/popular", response_model=List[PostStatsRead])
def get_popular_posts(
    *,
    session: Session = Depends(get_session),
    limit: int = 10,
    sort_by: str = "view_count"  # view_count, like_count, share_count,
    # comment_count
):
    """获取热门文章（按指定字段排序）"""
    valid_sort_fields = [
        "view_count", "like_count", "share_count", "comment_count"
    ]
    if sort_by not in valid_sort_fields:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"无效的排序字段，可选值: {', '.join(valid_sort_fields)}"
        )

    statement = (
        select(PostStats)
        .order_by(getattr(PostStats, sort_by).desc())
        .limit(limit)
    )
    post_stats = session.exec(statement).all()
    return post_stats

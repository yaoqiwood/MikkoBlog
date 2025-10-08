from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select, func

from app.db.session import get_session
from app.models.user import User
from app.models.post import Post
from app.models.moments import Moments
from app.models.postStats import PostStats

router = APIRouter()


@router.get("/stats/summary")
def get_stats_summary(
    *,
    session: Session = Depends(get_session)
):
    """获取系统总统计数据"""
    try:
        # 用户总数
        users_count = session.exec(select(func.count(User.id))).first() or 0

        # 文章总数
        posts_count = session.exec(select(func.count(Post.id))).first() or 0

        # 总浏览量（从PostStats表统计）
        total_views = session.exec(
            select(func.sum(PostStats.view_count))
        ).first() or 0

        # 活跃用户数（最近30天有活动的用户）
        thirty_days_ago = datetime.utcnow() - timedelta(days=30)

        # 统计最近30天有发布文章或说说的用户
        active_users_from_posts = session.exec(
            select(func.count(func.distinct(Post.user_id)))
            .where(Post.created_at >= thirty_days_ago)
        ).first() or 0

        active_users_from_moments = session.exec(
            select(func.count(func.distinct(Moments.user_id)))
            .where(Moments.created_at >= thirty_days_ago)
        ).first() or 0

        # 活跃用户数取最大值（因为可能有用户同时有文章和说说）
        active_users = max(
            active_users_from_posts,
            active_users_from_moments
        )

        return {
            "users": users_count,
            "posts": posts_count,
            "views": total_views,
            "active_users": active_users,
            "last_updated": datetime.utcnow().isoformat()
        }

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取统计数据失败: {str(e)}"
        )

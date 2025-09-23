from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from typing import List
from datetime import datetime

from app.db.session import get_db
from app.models.comment import Comment, CommentCreate, CommentUpdate, CommentRead
from app.models.user import User
from app.api.routers.auth import get_current_admin

router = APIRouter(prefix="/comments", tags=["comments"])


@router.get("/", response_model=List[CommentRead])
def list_comments(
    post_id: int = None,
    is_approved: bool = None,
    is_visible: bool = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
) -> List[CommentRead]:
    """获取评论列表"""
    statement = select(Comment).where(Comment.is_deleted == False)

    # 根据文章ID过滤
    if post_id is not None:
        statement = statement.where(Comment.post_id == post_id)

    # 根据审核状态过滤
    if is_approved is not None:
        statement = statement.where(Comment.is_approved == is_approved)

    # 根据可见性过滤
    if is_visible is not None:
        statement = statement.where(Comment.is_visible == is_visible)

    statement = statement.order_by(Comment.created_at.desc()).offset(skip).limit(limit)
    comments = db.exec(statement).all()
    return [CommentRead.model_validate(comment) for comment in comments]


@router.get("/{comment_id}", response_model=CommentRead)
def read_comment(comment_id: int, db: Session = Depends(get_db)) -> CommentRead:
    """获取单个评论详情"""
    comment = db.get(Comment, comment_id)
    if not comment or comment.is_deleted:
        raise HTTPException(status_code=404, detail="Comment not found")
    return CommentRead.model_validate(comment)


@router.post("/", response_model=CommentRead)
def create_comment(comment: CommentCreate, db: Session = Depends(get_db)) -> CommentRead:
    """创建新评论"""
    db_comment = Comment.model_validate(comment)
    db.add(db_comment)
    db.commit()
    db.refresh(db_comment)
    return CommentRead.model_validate(db_comment)


@router.put("/{comment_id}", response_model=CommentRead)
def update_comment(
    comment_id: int,
    comment_update: CommentUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin)
) -> CommentRead:
    """更新评论（需要管理员权限）"""
    comment = db.get(Comment, comment_id)
    if not comment or comment.is_deleted:
        raise HTTPException(status_code=404, detail="Comment not found")

    comment_data = comment_update.model_dump(exclude_unset=True)
    for field, value in comment_data.items():
        setattr(comment, field, value)

    comment.updated_at = datetime.utcnow()
    db.add(comment)
    db.commit()
    db.refresh(comment)
    return CommentRead.model_validate(comment)


@router.delete("/{comment_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_comment(
    comment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin)
) -> None:
    """软删除评论（需要管理员权限）"""
    comment = db.get(Comment, comment_id)
    if not comment or comment.is_deleted:
        raise HTTPException(status_code=404, detail="Comment not found")

    # 软删除：设置 is_deleted = True
    comment.is_deleted = True
    comment.updated_at = datetime.utcnow()
    db.add(comment)
    db.commit()
    return None


@router.patch("/{comment_id}/toggle-approval", response_model=CommentRead)
def toggle_comment_approval(
    comment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin)
) -> CommentRead:
    """切换评论审核状态（需要管理员权限）"""
    comment = db.get(Comment, comment_id)
    if not comment or comment.is_deleted:
        raise HTTPException(status_code=404, detail="Comment not found")

    # 切换审核状态
    comment.is_approved = not comment.is_approved
    comment.updated_at = datetime.utcnow()
    db.add(comment)
    db.commit()
    db.refresh(comment)
    return CommentRead.model_validate(comment)


@router.patch("/{comment_id}/toggle-visibility", response_model=CommentRead)
def toggle_comment_visibility(
    comment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin)
) -> CommentRead:
    """切换评论可见性（需要管理员权限）"""
    comment = db.get(Comment, comment_id)
    if not comment or comment.is_deleted:
        raise HTTPException(status_code=404, detail="Comment not found")

    # 切换可见性
    comment.is_visible = not comment.is_visible
    comment.updated_at = datetime.utcnow()
    db.add(comment)
    db.commit()
    db.refresh(comment)
    return CommentRead.model_validate(comment)


@router.get("/post/{post_id}", response_model=List[CommentRead])
def get_post_comments(
    post_id: int,
    include_replies: bool = True,
    db: Session = Depends(get_db)
) -> List[CommentRead]:
    """获取指定文章的评论列表（公开接口）"""
    statement = select(Comment).where(
        Comment.post_id == post_id,
        Comment.is_deleted == False,
        Comment.is_visible == True,
        Comment.is_approved == True
    )

    # 如果不包含回复，只获取顶级评论
    if not include_replies:
        statement = statement.where(Comment.parent_id == None)

    statement = statement.order_by(Comment.created_at.asc())
    comments = db.exec(statement).all()
    return [CommentRead.model_validate(comment) for comment in comments]

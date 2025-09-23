from datetime import datetime
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select

from app.db.session import get_db
from app.models.post import Post, PostCreate, PostRead, PostUpdate


router = APIRouter(prefix="/posts", tags=["posts"])


@router.get("/", response_model=List[PostRead])
def list_posts(db: Session = Depends(get_db)) -> List[PostRead]:
    # 只返回未删除的文章
    statement = select(Post).where(Post.is_deleted == 0).order_by(Post.created_at.desc())
    posts = db.exec(statement).all()
    return [PostRead.model_validate(post) for post in posts]


@router.post("/", response_model=PostRead, status_code=status.HTTP_201_CREATED)
def create_post(payload: PostCreate, db: Session = Depends(get_db)) -> PostRead:
    post = Post.model_validate(payload)
    db.add(post)
    db.commit()
    db.refresh(post)
    return PostRead.model_validate(post)


@router.get("/{post_id}", response_model=PostRead)
def read_post(post_id: int, db: Session = Depends(get_db)) -> PostRead:
    post = db.get(Post, post_id)
    if not post or post.is_deleted:
        raise HTTPException(status_code=404, detail="Post not found")
    return PostRead.model_validate(post)


@router.put("/{post_id}", response_model=PostRead)
def update_post(post_id: int, payload: PostUpdate, db: Session = Depends(get_db)) -> PostRead:
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
def toggle_post_visibility(post_id: int, db: Session = Depends(get_db)) -> PostRead:
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

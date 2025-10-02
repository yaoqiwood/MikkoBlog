"""
专栏管理API路由
"""
from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlmodel import Session, func, select

from app.api.routers.auth import get_current_admin, get_current_user_optional
from app.db.session import get_session
from app.models.columns import (
    Columns,
    ColumnsCreate,
    ColumnsListResponse,
    ColumnsRead,
    ColumnsUpdate,
    PostColumns,
)
from app.models.post import Post
from app.models.user import UserProfile

router = APIRouter()


@router.post(
    "/", response_model=ColumnsRead, status_code=status.HTTP_201_CREATED
)
def create_column(
    *,
    session: Session = Depends(get_session),
    column: ColumnsCreate,
    current_user=Depends(get_current_admin)
):
    """创建专栏（管理员）"""
    db_column = Columns.model_validate(column)
    session.add(db_column)
    session.commit()
    session.refresh(db_column)

    return get_column_with_details(session, db_column.id)


@router.get("/", response_model=ColumnsListResponse)
def list_columns(
    *,
    session: Session = Depends(get_session),
    page: int = Query(1, ge=1, description="页码"),
    limit: int = Query(10, ge=1, le=100, description="每页数量"),
    is_visible: Optional[bool] = Query(None, description="是否可见"),
    user_id: Optional[int] = Query(None, description="用户ID筛选"),
    current_user=Depends(get_current_user_optional)
):
    """获取专栏列表"""
    try:
        # 构建查询
        statement = select(Columns).where(Columns.is_deleted == 0)

        # 非管理员只能看到可见的专栏
        if (not current_user or
                not getattr(current_user, 'is_admin', False)):
            statement = statement.where(Columns.is_visible == 1)
        elif is_visible is not None:
            statement = statement.where(Columns.is_visible == is_visible)

        if user_id is not None:
            statement = statement.where(Columns.user_id == user_id)

        # 按排序顺序和创建时间排序
        statement = statement.order_by(
            Columns.sort_order.asc(), Columns.created_at.desc()
        )

        # 获取总数
        count_statement = select(func.count(Columns.id)).where(
            Columns.is_deleted == 0
        )
        if (not current_user or
                not getattr(current_user, 'is_admin', False)):
            count_statement = count_statement.where(Columns.is_visible == 1)
        elif is_visible is not None:
            count_statement = count_statement.where(
                Columns.is_visible == is_visible
            )
        if user_id is not None:
            count_statement = count_statement.where(Columns.user_id == user_id)

        total = session.exec(count_statement).one()

        # 分页查询
        offset = (page - 1) * limit
        columns = session.exec(statement.offset(offset).limit(limit)).all()

        # 构建响应数据
        items = []
        for column in columns:
            column_data = get_column_with_details(session, column.id)
            items.append(column_data)

        return ColumnsListResponse(
            items=items,
            total=total,
            page=page,
            limit=limit,
            has_more=len(items) == limit and (page * limit) < total,
        )

    except Exception as e:
        print(f"获取专栏列表失败: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="获取专栏列表失败"
        )


@router.get("/{column_id}", response_model=ColumnsRead)
def get_column(
    *,
    session: Session = Depends(get_session),
    column_id: int,
    current_user=Depends(get_current_user_optional)
):
    """获取单个专栏"""
    column = session.get(Columns, column_id)
    if not column or column.is_deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="专栏不存在"
        )

    # 非管理员只能查看可见的专栏
    if ((not current_user or not getattr(current_user, 'is_admin', False))
            and not column.is_visible):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="专栏不存在"
        )

    # 增加浏览量
    column.view_count += 1
    session.add(column)
    session.commit()

    return get_column_with_details(session, column_id)


@router.put("/{column_id}", response_model=ColumnsRead)
def update_column(
    *,
    session: Session = Depends(get_session),
    column_id: int,
    column: ColumnsUpdate,
    current_user=Depends(get_current_admin)
):
    """更新专栏（管理员）"""
    db_column = session.get(Columns, column_id)
    if not db_column or db_column.is_deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="专栏不存在"
        )

    column_data = column.model_dump(exclude_unset=True)
    for field, value in column_data.items():
        setattr(db_column, field, value)

    db_column.updated_at = datetime.utcnow()
    session.add(db_column)
    session.commit()

    return get_column_with_details(session, column_id)


@router.delete("/{column_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_column(
    *,
    session: Session = Depends(get_session),
    column_id: int,
    current_user=Depends(get_current_admin)
):
    """删除专栏（软删除）（管理员）"""
    column = session.get(Columns, column_id)
    if not column or column.is_deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="专栏不存在"
        )

    column.is_deleted = True
    column.updated_at = datetime.utcnow()
    session.add(column)
    session.commit()


@router.post(
    "/{column_id}/posts/{post_id}", status_code=status.HTTP_201_CREATED
)
def add_post_to_column(
    *,
    session: Session = Depends(get_session),
    column_id: int,
    post_id: int,
    sort_order: int = Query(0, description="排序顺序"),
    current_user=Depends(get_current_admin)
):
    """将文章添加到专栏（管理员）"""
    # 检查专栏是否存在
    column = session.get(Columns, column_id)
    if not column or column.is_deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="专栏不存在"
        )

    # 检查文章是否存在
    post = session.get(Post, post_id)
    if not post or post.is_deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="文章不存在"
        )

    # 检查是否已经关联
    existing = session.exec(
        select(PostColumns).where(
            PostColumns.post_id == post_id,
            PostColumns.column_id == column_id
        )
    ).first()

    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="文章已在该专栏中"
        )

    # 创建关联
    post_column = PostColumns(
        post_id=post_id,
        column_id=column_id,
        sort_order=sort_order
    )
    session.add(post_column)

    # 更新专栏文章数量
    column.post_count += 1
    session.add(column)

    session.commit()


@router.delete(
    "/{column_id}/posts/{post_id}", status_code=status.HTTP_204_NO_CONTENT
)
def remove_post_from_column(
    *,
    session: Session = Depends(get_session),
    column_id: int,
    post_id: int,
    current_user=Depends(get_current_admin)
):
    """从专栏中移除文章（管理员）"""
    # 查找关联记录
    post_column = session.exec(
        select(PostColumns).where(
            PostColumns.post_id == post_id,
            PostColumns.column_id == column_id
        )
    ).first()

    if not post_column:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="文章不在该专栏中"
        )

    # 删除关联
    session.delete(post_column)

    # 更新专栏文章数量
    column = session.get(Columns, column_id)
    if column:
        column.post_count = max(0, column.post_count - 1)
        session.add(column)

    session.commit()


def get_column_with_details(session: Session, column_id: int) -> ColumnsRead:
    """获取包含详细信息的专栏"""
    # 获取专栏
    column = session.get(Columns, column_id)
    if not column:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="专栏不存在"
        )

    # 获取用户信息
    user_profile = session.exec(
        select(UserProfile).where(UserProfile.user_id == column.user_id)
    ).first()

    # 获取专栏文章
    posts_query = session.exec(
        select(Post, PostColumns)
        .join(PostColumns, Post.id == PostColumns.post_id)
        .where(
            PostColumns.column_id == column_id,
            Post.is_deleted == 0,
            Post.is_published == 1
        )
        .order_by(
            PostColumns.sort_order.asc(), Post.created_at.desc()
        )
    ).all()

    posts = []
    for post, post_column in posts_query:
        posts.append({
            "id": post.id,
            "title": post.title,
            "summary": post.summary,
            "cover_image_url": post.cover_image_url,
            "created_at": post.created_at,
            "updated_at": post.updated_at,
            "sort_order": post_column.sort_order,
        })

    # 构建响应
    return ColumnsRead(
        id=column.id,
        name=column.name,
        description=column.description,
        cover_image_url=column.cover_image_url,
        sort_order=column.sort_order,
        is_visible=column.is_visible,
        is_deleted=column.is_deleted,
        user_id=column.user_id,
        post_count=len(posts),  # 使用实际查询到的文章数量
        view_count=column.view_count,
        created_at=column.created_at,
        updated_at=column.updated_at,
        user_nickname=user_profile.nickname if user_profile else None,
        posts=posts,
    )

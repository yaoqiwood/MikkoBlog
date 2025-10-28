from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlmodel import Session, select, func

from app.db.session import get_session
from app.api.routers.auth import get_current_admin, get_current_user
from app.models.moments import (
    Moments,
    MomentsImages,
    MomentsCreate,
    MomentsRead,
    MomentsUpdate,
    MomentsListResponse
)
from app.models.user import UserProfile
from app.models.attachment import Attachment

router = APIRouter(prefix="/moments", tags=["moments"])


@router.post(
    "/", response_model=MomentsRead, status_code=status.HTTP_201_CREATED
)
def create_moment(
    *,
    session: Session = Depends(get_session),
    moment: MomentsCreate,
    current_user=Depends(get_current_user)
):
    """创建说说"""
    # 创建说说记录
    db_moment = Moments(
        content=moment.content,
        user_id=current_user.id
    )
    session.add(db_moment)
    session.commit()
    session.refresh(db_moment)

    # 如果有图片，创建图片关联
    if moment.image_ids:
        for i, image_id in enumerate(moment.image_ids):
            # 验证图片是否存在
            attachment = session.get(Attachment, image_id)
            if attachment:
                moment_image = MomentsImages(
                    moment_id=db_moment.id,
                    attachment_id=image_id,
                    sort_order=i
                )
                session.add(moment_image)
        session.commit()

    return get_moment_with_details(session, db_moment.id)


@router.get("/", response_model=MomentsListResponse)
def list_moments(
    *,
    session: Session = Depends(get_session),
    page: int = Query(1, ge=1, description="页码"),
    limit: int = Query(10, ge=1, le=100, description="每页数量"),
    is_visible: Optional[bool] = Query(None, description="是否可见"),
    user_id: Optional[int] = Query(None, description="用户ID筛选")
):
    """获取说说列表"""
    try:
        # 构建查询
        statement = select(Moments).where(Moments.is_deleted == 0)

        if is_visible is not None:
            statement = statement.where(Moments.is_visible == is_visible)

        if user_id is not None:
            statement = statement.where(Moments.user_id == user_id)

        # 获取总数
        count_statement = select(func.count(Moments.id)).where(
            Moments.is_deleted == 0
        )
        if is_visible is not None:
            count_statement = count_statement.where(
                Moments.is_visible == is_visible
            )
        if user_id is not None:
            count_statement = count_statement.where(Moments.user_id == user_id)

        total = session.exec(count_statement).one()

        # 按更新时间倒序排序，如果更新时间为空则按创建时间倒序排序
        statement = statement.order_by(
            Moments.updated_at.desc().nullslast(),
            Moments.created_at.desc()
        )
        statement = statement.offset((page - 1) * limit).limit(limit)

        moments = session.exec(statement).all()

        # 获取详细信息
        moment_details = []
        for moment in moments:
            detail = get_moment_with_details(session, moment.id)
            moment_details.append(detail)

        return MomentsListResponse(
            items=moment_details,
            total=total,
            page=page,
            limit=limit,
            has_more=(page * limit) < total
        )
    except Exception as e:
        print(f"Error in list_moments: {e}")
        import traceback
        traceback.print_exc()
        return MomentsListResponse(
            items=[],
            total=0,
            page=page,
            limit=limit,
            has_more=False
        )


@router.get("/{moment_id}", response_model=MomentsRead)
def get_moment(
    *,
    session: Session = Depends(get_session),
    moment_id: int
):
    """获取单个说说"""
    moment = session.get(Moments, moment_id)
    if not moment or moment.is_deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="说说不存在"
        )

    return get_moment_with_details(session, moment_id)


@router.put("/{moment_id}", response_model=MomentsRead)
def update_moment(
    *,
    session: Session = Depends(get_session),
    moment_id: int,
    moment_update: MomentsUpdate,
    current_user=Depends(get_current_admin)
):
    """更新说说"""
    moment = session.get(Moments, moment_id)
    if not moment or moment.is_deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="说说不存在"
        )

    # 更新基本信息
    update_data = moment_update.model_dump(
        exclude_unset=True, exclude={"image_ids"}
    )
    for field, value in update_data.items():
        setattr(moment, field, value)

    moment.updated_at = datetime.utcnow()

    # 更新图片关联
    if moment_update.image_ids is not None:
        # 删除现有图片关联
        existing_images = session.exec(
            select(MomentsImages).where(
                MomentsImages.moment_id == moment_id
            )
        ).all()
        for img in existing_images:
            session.delete(img)

        # 添加新的图片关联
        for i, image_id in enumerate(moment_update.image_ids):
            attachment = session.get(Attachment, image_id)
            if attachment:
                moment_image = MomentsImages(
                    moment_id=moment_id,
                    attachment_id=image_id,
                    sort_order=i
                )
                session.add(moment_image)

    session.add(moment)
    session.commit()
    session.refresh(moment)

    return get_moment_with_details(session, moment_id)


@router.delete("/{moment_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_moment(
    *,
    session: Session = Depends(get_session),
    moment_id: int,
    current_user=Depends(get_current_admin)
):
    """删除说说（软删除）"""
    moment = session.get(Moments, moment_id)
    if not moment or moment.is_deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="说说不存在"
        )

    moment.is_deleted = True
    moment.updated_at = datetime.utcnow()
    session.add(moment)
    session.commit()


def get_moment_with_details(session: Session, moment_id: int) -> MomentsRead:
    """获取包含详细信息的说说"""
    # 获取说说
    moment = session.get(Moments, moment_id)
    if not moment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="说说不存在"
        )

    # 获取用户信息
    user_profile = session.exec(
        select(UserProfile).where(UserProfile.user_id == moment.user_id)
    ).first()

    # 获取图片信息
    images = []
    moment_images = session.exec(
        select(MomentsImages).where(MomentsImages.moment_id == moment_id)
    ).all()

    for moment_image in moment_images:
        attachment = session.get(Attachment, moment_image.attachment_id)
        if attachment:
            images.append({
                "id": attachment.id,
                "url": attachment.file_url,
                "filename": attachment.original_name,
                "sort_order": moment_image.sort_order
            })

    # 按排序顺序排列图片
    images.sort(key=lambda x: x["sort_order"])

    # 构建响应
    return MomentsRead(
        id=moment.id,
        content=moment.content,
        is_visible=moment.is_visible,
        is_deleted=moment.is_deleted,
        user_id=moment.user_id,
        created_at=moment.created_at,
        updated_at=moment.updated_at,
        user_nickname=user_profile.nickname if user_profile else None,
        user_avatar=user_profile.avatar if user_profile else None,
        images=images
    )

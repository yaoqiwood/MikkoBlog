from typing import List, Optional
from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    Query,
    UploadFile,
    File,
    Form,
)
from sqlmodel import Session, select, func, and_, or_
import os
import uuid
from datetime import datetime

from app.api.routers.auth import get_current_admin, get_current_user
from app.db.session import get_db
from app.models.attachment import (
    Attachment,
    AttachmentRead,
    AttachmentCreate,
    AttachmentUpdate,
    FileCategory,
    AttachmentStatus,
)
from app.models.user import UserRead

router = APIRouter(prefix="/attachments", tags=["attachments"])


@router.get("/", response_model=List[AttachmentRead])
def list_attachments(
    file_category: Optional[FileCategory] = Query(None, description="文件分类"),
    file_type: Optional[str] = Query(None, description="文件类型"),
    is_public: Optional[bool] = Query(None, description="是否公开"),
    is_featured: Optional[bool] = Query(None, description="是否精选"),
    status: Optional[AttachmentStatus] = Query(None, description="文件状态"),
    uploaded_by: Optional[int] = Query(None, description="上传者ID"),
    related_type: Optional[str] = Query(None, description="关联类型"),
    related_id: Optional[int] = Query(None, description="关联ID"),
    search: Optional[str] = Query(None, description="搜索关键词"),
    page: int = Query(1, ge=1, description="页码"),
    page_size: int = Query(20, ge=1, le=100, description="每页数量"),
    _: UserRead = Depends(get_current_admin),
    db: Session = Depends(get_db)
) -> List[AttachmentRead]:
    """获取附件列表（需要管理员权限）"""
    query = select(Attachment)

    # 如果没有指定status参数，默认排除已删除的附件
    # 如果指定了status参数，则根据参数筛选（包括已删除的）
    if status is None:
        query = query.where(Attachment.status != AttachmentStatus.DELETED)
    else:
        query = query.where(Attachment.status == status)

    # 应用筛选条件
    if file_category:
        query = query.where(Attachment.file_category == file_category)
    if file_type:
        query = query.where(Attachment.file_type.like(f"%{file_type}%"))
    if is_public is not None:
        query = query.where(Attachment.is_public == is_public)
    if is_featured is not None:
        query = query.where(Attachment.is_featured == is_featured)
    if uploaded_by:
        query = query.where(Attachment.uploaded_by == uploaded_by)
    if related_type:
        query = query.where(Attachment.related_type == related_type)
    if related_id:
        query = query.where(Attachment.related_id == related_id)
    if search:
        search_filter = or_(
            Attachment.filename.like(f"%{search}%"),
            Attachment.title.like(f"%{search}%"),
            Attachment.description.like(f"%{search}%"),
            Attachment.tags.like(f"%{search}%")
        )
        query = query.where(search_filter)

    # 排序和分页
    query = query.order_by(Attachment.created_at.desc())
    query = query.offset((page - 1) * page_size).limit(page_size)

    attachments = db.exec(query).all()
    return [
        AttachmentRead.model_validate(attachment) for attachment in attachments
    ]


@router.get("/public", response_model=List[AttachmentRead])
def list_public_attachments(
    file_category: Optional[FileCategory] = Query(None, description="文件分类"),
    file_type: Optional[str] = Query(None, description="文件类型"),
    is_featured: Optional[bool] = Query(None, description="是否精选"),
    search: Optional[str] = Query(None, description="搜索关键词"),
    page: int = Query(1, ge=1, description="页码"),
    page_size: int = Query(20, ge=1, le=100, description="每页数量"),
    db: Session = Depends(get_db)
) -> List[AttachmentRead]:
    """获取公开附件列表（无需权限）"""
    query = select(Attachment).where(
        and_(
            Attachment.is_public is True,
            Attachment.status == AttachmentStatus.ACTIVE
        )
    )

    # 应用筛选条件
    if file_category:
        query = query.where(Attachment.file_category == file_category)
    if file_type:
        query = query.where(Attachment.file_type.like(f"%{file_type}%"))
    if is_featured is not None:
        query = query.where(Attachment.is_featured == is_featured)
    if search:
        search_filter = or_(
            Attachment.filename.like(f"%{search}%"),
            Attachment.title.like(f"%{search}%"),
            Attachment.description.like(f"%{search}%"),
            Attachment.tags.like(f"%{search}%")
        )
        query = query.where(search_filter)

    # 排序和分页
    query = query.order_by(Attachment.created_at.desc())
    query = query.offset((page - 1) * page_size).limit(page_size)

    attachments = db.exec(query).all()
    return [
        AttachmentRead.model_validate(attachment) for attachment in attachments
    ]


@router.get("/{attachment_id}", response_model=AttachmentRead)
def get_attachment(
    attachment_id: int,
    db: Session = Depends(get_db)
) -> AttachmentRead:
    """获取单个附件详情"""
    attachment = db.get(Attachment, attachment_id)
    if not attachment or attachment.status == AttachmentStatus.DELETED:
        raise HTTPException(status_code=404, detail="附件不存在")

    # 增加查看次数
    attachment.view_count += 1
    db.add(attachment)
    db.commit()
    db.refresh(attachment)

    return AttachmentRead.model_validate(attachment)


@router.post("/upload", response_model=AttachmentRead)
def upload_attachment(
    file: UploadFile = File(...),
    title: Optional[str] = Form(None),
    description: Optional[str] = Form(None),
    tags: Optional[str] = Form(None),
    is_public: bool = Form(True),
    is_featured: bool = Form(False),
    related_type: Optional[str] = Form(None),
    related_id: Optional[int] = Form(None),
    current_user: UserRead = Depends(get_current_user),
    db: Session = Depends(get_db)
) -> AttachmentRead:
    """上传附件"""
    print(f"接收到的表单数据: title={title}, description={description}, "
          f"tags={tags}")  # 调试信息
    # 生成唯一文件名
    file_extension = os.path.splitext(file.filename)[1].lower()
    unique_filename = f"{uuid.uuid4().hex}{file_extension}"

    # 确定文件分类
    file_category = FileCategory.OTHER
    if file.content_type and file.content_type.startswith('image/'):
        file_category = FileCategory.IMAGE
    elif file.content_type and file.content_type.startswith('video/'):
        file_category = FileCategory.VIDEO
    elif file.content_type and file.content_type.startswith('audio/'):
        file_category = FileCategory.AUDIO
    elif file.content_type and file.content_type in [
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.'
        'wordprocessingml.document'
    ]:
        file_category = FileCategory.DOCUMENT

    # 确定存储路径
    upload_dir = "uploads"
    if file_category == FileCategory.IMAGE:
        upload_dir = "uploads/images"
    elif file_category == FileCategory.DOCUMENT:
        upload_dir = "uploads/documents"
    elif file_category == FileCategory.VIDEO:
        upload_dir = "uploads/videos"
    elif file_category == FileCategory.AUDIO:
        upload_dir = "uploads/audio"
    else:
        upload_dir = "uploads/others"

    # 确保目录存在
    os.makedirs(upload_dir, exist_ok=True)

    file_path = os.path.join(upload_dir, unique_filename)
    file_url = f"/{file_path}"

    # 保存文件
    with open(file_path, "wb") as buffer:
        content = file.file.read()
        buffer.write(content)

    # 获取文件大小
    file_size = len(content)

    # 如果是图片，获取尺寸信息
    width = None
    height = None
    if file_category == FileCategory.IMAGE:
        try:
            from PIL import Image
            with Image.open(file_path) as img:
                width, height = img.size
        except ImportError:
            pass  # PIL不可用，跳过尺寸获取

    # 创建附件记录
    attachment_data = AttachmentCreate(
        filename=unique_filename,
        original_name=file.filename,
        file_path=file_path,
        file_url=file_url,
        file_size=file_size,
        file_type=file.content_type or "application/octet-stream",
        file_extension=file_extension,
        file_category=file_category,
        width=width,
        height=height,
        title=title,
        description=description,
        tags=tags,
        is_public=is_public,
        is_featured=is_featured,
        uploaded_by=current_user.id,
        related_type=related_type,
        related_id=related_id
    )

    attachment = Attachment.model_validate(attachment_data)
    db.add(attachment)
    db.commit()
    db.refresh(attachment)

    return AttachmentRead.model_validate(attachment)


@router.put("/{attachment_id}", response_model=AttachmentRead)
def update_attachment(
    attachment_id: int,
    attachment_data: AttachmentUpdate,
    _: UserRead = Depends(get_current_admin),
    db: Session = Depends(get_db)
) -> AttachmentRead:
    """更新附件信息（需要管理员权限）"""
    attachment = db.get(Attachment, attachment_id)
    if not attachment or attachment.status == AttachmentStatus.DELETED:
        raise HTTPException(status_code=404, detail="附件不存在")

    update_data = attachment_data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(attachment, key, value)

    db.add(attachment)
    db.commit()
    db.refresh(attachment)

    return AttachmentRead.model_validate(attachment)


@router.delete("/{attachment_id}/soft-delete")
def soft_delete_attachment(
    attachment_id: int,
    _: UserRead = Depends(get_current_admin),
    db: Session = Depends(get_db)
) -> dict:
    """软删除附件（需要管理员权限）"""
    attachment = db.get(Attachment, attachment_id)
    if not attachment or attachment.status == AttachmentStatus.DELETED:
        raise HTTPException(status_code=404, detail="附件不存在")

    # 软删除
    attachment.status = AttachmentStatus.DELETED
    attachment.deleted_at = datetime.utcnow()

    db.add(attachment)
    db.commit()

    return {"message": "附件删除成功"}


@router.post("/{attachment_id}/restore")
def restore_attachment(
    attachment_id: int,
    _: UserRead = Depends(get_current_admin),
    db: Session = Depends(get_db)
) -> dict:
    """恢复已删除的附件（需要管理员权限）"""
    attachment = db.get(Attachment, attachment_id)
    if not attachment:
        raise HTTPException(status_code=404, detail="附件不存在")

    if attachment.status != AttachmentStatus.DELETED:
        raise HTTPException(status_code=400, detail="附件未被删除")

    attachment.status = AttachmentStatus.ACTIVE
    attachment.deleted_at = None

    db.add(attachment)
    db.commit()

    return {"message": "附件恢复成功"}


@router.delete("/{attachment_id}/hard-delete")
def hard_delete_attachment(
    attachment_id: int,
    _: UserRead = Depends(get_current_admin),
    db: Session = Depends(get_db)
) -> dict:
    """硬删除附件（需要管理员权限）"""
    attachment = db.get(Attachment, attachment_id)
    if not attachment:
        raise HTTPException(status_code=404, detail="附件不存在")

    if attachment.status != AttachmentStatus.DELETED:
        raise HTTPException(status_code=400, detail="只能永久删除已删除的附件")

    # 删除文件
    try:
        if attachment.file_path and os.path.exists(attachment.file_path):
            os.remove(attachment.file_path)
    except Exception as e:
        print(f"删除文件失败: {e}")
        # 继续删除数据库记录，即使文件删除失败

    # 从数据库中删除记录
    db.delete(attachment)
    db.commit()

    return {"message": "附件永久删除成功"}


@router.post("/batch/hard-delete")
def batch_hard_delete_attachments(
    attachment_ids: List[int],
    _: UserRead = Depends(get_current_admin),
    db: Session = Depends(get_db)
) -> dict:
    """批量硬删除附件（需要管理员权限）"""
    if not attachment_ids:
        raise HTTPException(status_code=400, detail="请选择要删除的附件")

    # 获取所有已删除的附件
    attachments = db.exec(
        select(Attachment).where(
            and_(
                Attachment.id.in_(attachment_ids),
                Attachment.status == AttachmentStatus.DELETED
            )
        )
    ).all()

    if not attachments:
        raise HTTPException(status_code=404, detail="没有找到可删除的附件")

    deleted_count = 0
    for attachment in attachments:
        # 删除文件
        try:
            if attachment.file_path and os.path.exists(attachment.file_path):
                os.remove(attachment.file_path)
        except Exception as e:
            print(f"删除文件失败: {e}")
            # 继续删除数据库记录，即使文件删除失败

        # 从数据库中删除记录
        db.delete(attachment)
        deleted_count += 1

    db.commit()

    return {"message": f"成功永久删除 {deleted_count} 个附件"}


@router.get("/stats/summary")
def get_attachment_stats(
    _: UserRead = Depends(get_current_admin),
    db: Session = Depends(get_db)
) -> dict:
    """获取附件统计信息（需要管理员权限）"""
    # 总数量
    total_count = db.exec(
        select(func.count(Attachment.id)).where(
            Attachment.status != AttachmentStatus.DELETED
        )
    ).first()

    # 按分类统计
    category_stats = db.exec(
        select(Attachment.file_category, func.count(Attachment.id))
        .where(Attachment.status != AttachmentStatus.DELETED)
        .group_by(Attachment.file_category)
    ).all()

    # 按状态统计
    status_stats = db.exec(
        select(Attachment.status, func.count(Attachment.id))
        .group_by(Attachment.status)
    ).all()

    # 总文件大小
    total_size = db.exec(
        select(func.sum(Attachment.file_size))
        .where(Attachment.status != AttachmentStatus.DELETED)
    ).first() or 0

    return {
        "total_count": total_count,
        "total_size": total_size,
        "category_stats": dict(category_stats),
        "status_stats": dict(status_stats)
    }

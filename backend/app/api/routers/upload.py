import os
import uuid
from datetime import datetime
from fastapi import APIRouter, Depends, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from sqlmodel import Session, select

from app.db.session import get_db
from app.api.routers.auth import get_current_user
from app.models.user import UserRead, UserProfile

router = APIRouter(prefix="/upload", tags=["upload"])

# 确保上传目录存在
UPLOAD_DIR = "uploads/images"
os.makedirs(UPLOAD_DIR, exist_ok=True)

ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif", ".webp", ".svg"}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB


@router.post("/image")
async def upload_image(
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """
    上传图片文件
    """
    try:
        # 检查文件类型
        file_extension = os.path.splitext(file.filename)[1].lower()
        if file_extension not in ALLOWED_EXTENSIONS:
            raise HTTPException(
                status_code=400,
                detail=f"不支持的文件类型。支持的类型: {', '.join(ALLOWED_EXTENSIONS)}"
            )

        # 检查文件大小
        content = await file.read()
        if len(content) > MAX_FILE_SIZE:
            raise HTTPException(
                status_code=400,
                detail=f"文件大小超过限制。最大允许: {MAX_FILE_SIZE // (1024*1024)}MB"
            )

        # 生成唯一文件名
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        unique_id = str(uuid.uuid4())[:8]
        filename = f"{timestamp}_{unique_id}{file_extension}"

        # 保存文件
        file_path = os.path.join(UPLOAD_DIR, filename)
        with open(file_path, "wb") as buffer:
            buffer.write(content)

        # 生成访问URL
        file_url = f"/uploads/images/{filename}"

        return JSONResponse({
            "success": True,
            "url": file_url,
            "filename": filename,
            "size": len(content)
        })

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"文件上传失败: {str(e)}"
        )


@router.get("/images/{filename}")
async def get_image(filename: str):
    """
    获取上传的图片
    """
    try:
        file_path = os.path.join(UPLOAD_DIR, filename)
        if not os.path.exists(file_path):
            raise HTTPException(status_code=404, detail="图片不存在")

        from fastapi.responses import FileResponse
        return FileResponse(file_path)

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"获取图片失败: {str(e)}"
        )


@router.post("/avatar")
async def upload_avatar(
    file: UploadFile = File(...),
    current_user: UserRead = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    上传用户头像
    """
    try:
        # 检查文件类型
        file_extension = os.path.splitext(file.filename)[1].lower()
        if file_extension not in ALLOWED_EXTENSIONS:
            raise HTTPException(
                status_code=400,
                detail=f"不支持的文件类型。支持的类型: {', '.join(ALLOWED_EXTENSIONS)}"
            )

        # 检查文件大小
        content = await file.read()
        if len(content) > MAX_FILE_SIZE:
            raise HTTPException(
                status_code=400,
                detail=f"文件大小超过限制。最大允许: {MAX_FILE_SIZE // (1024*1024)}MB"
            )

        # 生成唯一文件名
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        unique_id = str(uuid.uuid4())[:8]
        filename = f"{timestamp}_{unique_id}{file_extension}"

        # 保存文件
        file_path = os.path.join(UPLOAD_DIR, filename)
        with open(file_path, "wb") as buffer:
            buffer.write(content)

        # 生成访问URL
        file_url = f"/uploads/images/{filename}"

        # 更新用户个人信息表中的头像
        user_profile_query = select(UserProfile).where(
            UserProfile.user_id == current_user.id
        )
        user_profile = db.exec(user_profile_query).first()

        if user_profile:
            # 更新现有记录
            user_profile.avatar = file_url
            user_profile.updated_at = datetime.utcnow()
            db.add(user_profile)
        else:
            # 创建新记录
            new_profile = UserProfile(
                user_id=current_user.id,
                avatar=file_url,
                created_at=datetime.utcnow(),
                updated_at=datetime.utcnow()
            )
            db.add(new_profile)

        db.commit()

        return JSONResponse({
            "success": True,
            "data": {
                "url": file_url,
                "filename": filename,
                "size": len(content)
            },
            "message": "头像上传成功"
        })

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"头像上传失败: {str(e)}"
        )


@router.delete("/avatar")
async def reset_avatar(
    current_user: UserRead = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    重置用户头像为默认头像
    """
    try:
        # 查询用户个人信息表
        user_profile_query = select(UserProfile).where(
            UserProfile.user_id == current_user.id
        )
        user_profile = db.exec(user_profile_query).first()

        if user_profile:
            # 清空头像字段
            user_profile.avatar = None
            user_profile.updated_at = datetime.utcnow()
            db.add(user_profile)
        else:
            # 创建新记录，头像字段为空
            new_profile = UserProfile(
                user_id=current_user.id,
                avatar=None,
                created_at=datetime.utcnow(),
                updated_at=datetime.utcnow()
            )
            db.add(new_profile)

        db.commit()

        return JSONResponse({
            "success": True,
            "message": "头像已重置为默认头像"
        })

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"重置头像失败: {str(e)}"
        )

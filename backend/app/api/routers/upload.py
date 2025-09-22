import os
import uuid
from datetime import datetime
from fastapi import APIRouter, Depends, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from sqlmodel import Session

from app.db.session import get_db
from app.core.config import settings

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

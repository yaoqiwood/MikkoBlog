"""
图片搜索API路由
"""
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlmodel import Session

from app.api.routers.auth import get_current_admin, get_current_user_optional
from app.db.session import get_session
from app.services.image_search import image_search_service

router = APIRouter()


class ImageSearchRequest(BaseModel):
    """图片搜索请求"""
    tags: List[str]
    count: Optional[int] = 10
    orientation: Optional[str] = "landscape"


class ImageSearchResponse(BaseModel):
    """图片搜索响应"""
    id: str
    url: str
    download_url: str
    description: str
    alt_description: str
    width: int
    height: int
    author: str
    author_url: str
    source: str


class RandomCoverRequest(BaseModel):
    """随机封面请求"""
    tags: List[str]


class RandomCoverResponse(BaseModel):
    """随机封面响应"""
    cover_url: str
    attachment_id: Optional[int] = None


@router.post("/search", response_model=List[ImageSearchResponse])
def search_images(
    request: ImageSearchRequest,
    current_user=Depends(get_current_user_optional)
):
    """
    搜索图片

    支持的标签：
    - 二次元, 风景, 美女, 科技, 编程, 代码, 开发, 设计, 艺术
    - 自然, 城市, 建筑, 抽象, 商务, 教育, 医疗, 运动, 音乐, 食物, 旅行
    """
    try:
        images = image_search_service.search_images(
            tags=request.tags,
            count=request.count,
            orientation=request.orientation
        )

        return [ImageSearchResponse(**image) for image in images]

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"图片搜索失败: {str(e)}"
        )


@router.post("/random-cover", response_model=RandomCoverResponse)
def get_random_cover(
    request: RandomCoverRequest,
    session: Session = Depends(get_session),
    current_user=Depends(get_current_admin)
):
    """
    获取随机封面图片（管理员）

    自动下载图片并保存为附件，返回本地URL
    """
    try:
        user_id = getattr(current_user, 'id', 1)

        cover_url = image_search_service.get_random_cover_image(
            tags=request.tags,
            user_id=user_id
        )

        if not cover_url:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="未找到合适的封面图片"
            )

        return RandomCoverResponse(cover_url=cover_url)

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"获取随机封面失败: {str(e)}"
        )


@router.get("/tags")
async def get_available_tags():
    """获取可用的搜索标签"""
    return {
        "tags": [
            {"name": "二次元", "english": "anime"},
            {"name": "风景", "english": "landscape"},
            {"name": "美女", "english": "portrait"},
            {"name": "科技", "english": "technology"},
            {"name": "编程", "english": "programming"},
            {"name": "代码", "english": "code"},
            {"name": "开发", "english": "development"},
            {"name": "设计", "english": "design"},
            {"name": "艺术", "english": "art"},
            {"name": "自然", "english": "nature"},
            {"name": "城市", "english": "city"},
            {"name": "建筑", "english": "architecture"},
            {"name": "抽象", "english": "abstract"},
            {"name": "商务", "english": "business"},
            {"name": "教育", "english": "education"},
            {"name": "医疗", "english": "medical"},
            {"name": "运动", "english": "sports"},
            {"name": "音乐", "english": "music"},
            {"name": "食物", "english": "food"},
            {"name": "旅行", "english": "travel"}
        ]
    }

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select

from app.api.routers.auth import get_current_admin
from app.db.session import get_db
from app.models.system import SystemDefault, SystemDefaultRead, SystemDefaultUpdate, SystemDefaultCreate

router = APIRouter(prefix="/system", tags=["system"])


@router.get("/defaults", response_model=List[SystemDefaultRead])
def list_defaults(
    category: Optional[str] = Query(None, description="按分类筛选"),
    is_public: Optional[bool] = Query(None, description="是否公开"),
    _: SystemDefaultRead = Depends(get_current_admin),
    db: Session = Depends(get_db)
) -> List[SystemDefaultRead]:
    """获取系统默认参数列表（需要管理员权限）"""
    query = select(SystemDefault)

    if category:
        query = query.where(SystemDefault.category == category)
    if is_public is not None:
        query = query.where(SystemDefault.is_public == is_public)

    query = query.order_by(SystemDefault.category, SystemDefault.sort_order, SystemDefault.key_name)

    defaults = db.exec(query).all()
    return [SystemDefaultRead.model_validate(default) for default in defaults]


@router.get("/defaults/public", response_model=List[SystemDefaultRead])
def list_public_defaults(
    category: Optional[str] = Query(None, description="按分类筛选"),
    db: Session = Depends(get_db)
) -> List[SystemDefaultRead]:
    """获取公开的系统默认参数（无需权限）"""
    query = select(SystemDefault).where(SystemDefault.is_public == True)

    if category:
        query = query.where(SystemDefault.category == category)

    query = query.order_by(SystemDefault.category, SystemDefault.sort_order, SystemDefault.key_name)

    defaults = db.exec(query).all()
    return [SystemDefaultRead.model_validate(default) for default in defaults]


@router.get("/defaults/{default_id}", response_model=SystemDefaultRead)
def get_default(
    default_id: int,
    _: SystemDefaultRead = Depends(get_current_admin),
    db: Session = Depends(get_db)
) -> SystemDefaultRead:
    """获取单个系统默认参数（需要管理员权限）"""
    default = db.get(SystemDefault, default_id)
    if not default:
        raise HTTPException(status_code=404, detail="参数不存在")
    return SystemDefaultRead.model_validate(default)


@router.get("/defaults/category/{category}", response_model=List[SystemDefaultRead])
def get_defaults_by_category(
    category: str,
    is_public: Optional[bool] = Query(None, description="是否公开"),
    db: Session = Depends(get_db)
) -> List[SystemDefaultRead]:
    """按分类获取系统默认参数（公开接口）"""
    query = select(SystemDefault).where(SystemDefault.category == category)

    if is_public is not None:
        query = query.where(SystemDefault.is_public == is_public)
    else:
        # 默认只返回公开参数
        query = query.where(SystemDefault.is_public == True)

    query = query.order_by(SystemDefault.sort_order, SystemDefault.key_name)

    defaults = db.exec(query).all()
    return [SystemDefaultRead.model_validate(default) for default in defaults]


@router.get("/defaults/key/{category}/{key_name}", response_model=SystemDefaultRead)
def get_default_by_key(
    category: str,
    key_name: str,
    db: Session = Depends(get_db)
) -> SystemDefaultRead:
    """根据分类和键名获取系统默认参数（公开接口）"""
    default = db.exec(
        select(SystemDefault).where(
            SystemDefault.category == category,
            SystemDefault.key_name == key_name,
            SystemDefault.is_public == True
        )
    ).first()

    if not default:
        raise HTTPException(status_code=404, detail="参数不存在")

    return SystemDefaultRead.model_validate(default)


@router.post("/defaults", response_model=SystemDefaultRead)
def create_default(
    default_data: SystemDefaultCreate,
    _: SystemDefaultRead = Depends(get_current_admin),
    db: Session = Depends(get_db)
) -> SystemDefaultRead:
    """创建系统默认参数（需要管理员权限）"""
    # 检查是否已存在相同的分类和键名
    existing = db.exec(
        select(SystemDefault).where(
            SystemDefault.category == default_data.category,
            SystemDefault.key_name == default_data.key_name
        )
    ).first()

    if existing:
        raise HTTPException(status_code=400, detail="该分类和键名的参数已存在")

    default = SystemDefault.model_validate(default_data)
    db.add(default)
    db.commit()
    db.refresh(default)

    return SystemDefaultRead.model_validate(default)


@router.put("/defaults/{default_id}", response_model=SystemDefaultRead)
def update_default(
    default_id: int,
    default_data: SystemDefaultUpdate,
    _: SystemDefaultRead = Depends(get_current_admin),
    db: Session = Depends(get_db)
) -> SystemDefaultRead:
    """更新系统默认参数（需要管理员权限）"""
    default = db.get(SystemDefault, default_id)
    if not default:
        raise HTTPException(status_code=404, detail="参数不存在")

    if not default.is_editable:
        raise HTTPException(status_code=400, detail="该参数不可编辑")

    update_data = default_data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(default, key, value)

    db.add(default)
    db.commit()
    db.refresh(default)

    return SystemDefaultRead.model_validate(default)


@router.delete("/defaults/{default_id}")
def delete_default(
    default_id: int,
    _: SystemDefaultRead = Depends(get_current_admin),
    db: Session = Depends(get_db)
) -> dict:
    """删除系统默认参数（需要管理员权限）"""
    default = db.get(SystemDefault, default_id)
    if not default:
        raise HTTPException(status_code=404, detail="参数不存在")

    if not default.is_editable:
        raise HTTPException(status_code=400, detail="该参数不可删除")

    db.delete(default)
    db.commit()

    return {"message": "参数删除成功"}


@router.get("/defaults/categories", response_model=List[str])
def get_categories(
    db: Session = Depends(get_db)
) -> List[str]:
    """获取所有分类列表（公开接口）"""
    categories = db.exec(
        select(SystemDefault.category).distinct().where(SystemDefault.is_public == True)
    ).all()
    return sorted(categories)

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, Request
from sqlmodel import Session, select

from app.api.routers.auth import get_current_admin
from app.db.session import get_db
from app.models.system import (
    SystemDefault,
    SystemDefaultRead,
    SystemDefaultUpdate,
    SystemDefaultCreate,
)

router = APIRouter(prefix="/system", tags=["system"])


@router.get("/defaults/categories", response_model=List[str])
def get_categories(
    db: Session = Depends(get_db)
) -> List[str]:
    """获取所有分类列表（公开接口）"""
    categories = db.exec(
        select(SystemDefault.category)
        .distinct()
    ).all()
    return sorted(categories)


@router.get("/defaults", response_model=List[SystemDefaultRead])
def list_defaults(
    request: Request,
    category: Optional[str] = Query(None, description="按分类筛选"),
    is_public: Optional[bool] = Query(None, description="是否公开"),
    _: SystemDefaultRead = Depends(get_current_admin),
    db: Session = Depends(get_db)
) -> List[SystemDefaultRead]:
    """获取系统默认参数列表（需要管理员权限）"""
    print(f"🔍 [DEBUG] 接收到的参数: category={category}, is_public={is_public}")
    print(f"🔍 [DEBUG] 请求URL: {request.url}")
    print(f"🔍 [DEBUG] 查询参数: {request.query_params}")

    # 手动解析嵌套参数 params[category]
    actual_category = category
    if not actual_category and 'params[category]' in request.query_params:
        actual_category = request.query_params['params[category]']
        print(f"🔍 [DEBUG] 从嵌套参数解析到: category={actual_category}")

    query = select(SystemDefault)

    if actual_category:
        query = query.where(SystemDefault.category == actual_category)
    if is_public is not None:
        query = query.where(SystemDefault.is_public == is_public)

    query = query.order_by(
        SystemDefault.category,
        SystemDefault.sort_order,
        SystemDefault.key_name,
    )

    defaults = db.exec(query).all()
    return [SystemDefaultRead.model_validate(default) for default in defaults]


@router.get("/defaults/public", response_model=List[SystemDefaultRead])
def list_public_defaults(
    category: Optional[str] = Query(None, description="按分类筛选"),
    db: Session = Depends(get_db)
) -> List[SystemDefaultRead]:
    """获取公开的系统默认参数（无需权限）"""
    query = select(SystemDefault).where(SystemDefault.is_public == 1)

    if category:
        query = query.where(SystemDefault.category == category)

    query = query.order_by(
        SystemDefault.category,
        SystemDefault.sort_order,
        SystemDefault.key_name,
    )

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


@router.get(
    "/defaults/category/{category}", response_model=List[SystemDefaultRead]
)
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
        query = query.where(SystemDefault.is_public == 1)

    query = query.order_by(
        SystemDefault.sort_order,
        SystemDefault.key_name,
    )

    defaults = db.exec(query).all()
    return [SystemDefaultRead.model_validate(default) for default in defaults]


@router.get(
    "/defaults/key/{category}/{key_name}", response_model=SystemDefaultRead
)
def get_default_by_key(
    category: str,
    key_name: str,
    db: Session = Depends(get_db)
) -> SystemDefaultRead:
    """根据分类和键名获取系统默认参数（公开接口）"""
    default = db.exec(
        select(SystemDefault).where(
            SystemDefault.category == category,
            SystemDefault.key_name == key_name
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


@router.put(
    "/defaults/key/{category}/{key_name}", response_model=SystemDefaultRead
)
def update_default_by_key(
    category: str,
    key_name: str,
    default_data: SystemDefaultUpdate,
    _: SystemDefaultRead = Depends(get_current_admin),
    db: Session = Depends(get_db)
) -> SystemDefaultRead:
    """根据分类和键名更新系统默认参数（需要管理员权限）"""
    default = db.exec(
        select(SystemDefault).where(
            SystemDefault.category == category,
            SystemDefault.key_name == key_name
        )
    ).first()

    if not default:
        raise HTTPException(status_code=404, detail="参数不存在")

    if not default.is_editable:
        raise HTTPException(status_code=400, detail="该参数不可编辑")

    update_data = default_data.model_dump(exclude_unset=True)

    # 根据数据类型验证和转换key_value
    if 'key_value' in update_data and update_data['key_value'] is not None:
        value = update_data['key_value']

        # 如果同时更新了data_type，使用新的data_type，否则使用现有的
        target_data_type = update_data.get('data_type', default.data_type)

        try:
            if target_data_type == 'number':
                # 确保数值类型
                if isinstance(value, (int, float)):
                    value = str(value)
                elif isinstance(value, str):
                    # 验证字符串是否为有效数字
                    float(value)
                else:
                    raise ValueError("Invalid number format")
            elif target_data_type == 'boolean':
                # 确保布尔类型
                if isinstance(value, bool):
                    value = str(value).lower()
                elif isinstance(value, str):
                    valid_bools = ['true', 'false', '1', '0', 'yes', 'no']
                    if value.lower() not in valid_bools:
                        raise ValueError("Invalid boolean format")
                    value = value.lower()
                else:
                    raise ValueError("Invalid boolean format")
            elif target_data_type == 'json':
                # 确保JSON格式
                if isinstance(value, str):
                    import json
                    json.loads(value)  # 验证JSON格式
                else:
                    import json
                    value = json.dumps(value)
            # string 和 url 类型不需要特殊处理

            update_data['key_value'] = value

        except (ValueError, TypeError) as e:
            raise HTTPException(
                status_code=422,
                detail=f"数据类型验证失败: {str(e)}"
            )
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

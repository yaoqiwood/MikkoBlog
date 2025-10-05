from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select, func
import json

from app.api.routers.auth import get_current_admin
from app.db.session import get_session
from app.models.system_setting import (
    SystemSetting, SystemSettingCreate, SystemSettingRead,
    SystemSettingUpdate, SystemSettingBatchUpdate, AISettingConfig
)
from app.models.user import User

router = APIRouter(tags=["system-setting"])


@router.get("/categories", response_model=List[str])
def get_categories(
    session: Session = Depends(get_session)
) -> List[str]:
    """获取所有设置分类"""
    statement = select(SystemSetting.category).distinct().order_by(SystemSetting.category)
    categories = session.exec(statement).all()
    return categories


@router.get("/category/{category}", response_model=List[SystemSettingRead])
def get_settings_by_category(
    category: str,
    session: Session = Depends(get_session)
) -> List[SystemSettingRead]:
    """根据分类获取系统设置"""
    statement = select(SystemSetting).where(SystemSetting.category == category).order_by(SystemSetting.sort_order)
    settings = session.exec(statement).all()
    return settings


@router.get("/key/{category}/{key_name}", response_model=SystemSettingRead)
def get_setting_by_key(
    category: str,
    key_name: str,
    session: Session = Depends(get_session)
) -> SystemSettingRead:
    """根据分类和键名获取单个设置"""
    statement = select(SystemSetting).where(
        SystemSetting.category == category,
        SystemSetting.key_name == key_name
    )
    setting = session.exec(statement).first()
    if not setting:
        raise HTTPException(status_code=404, detail="设置不存在")
    return setting


@router.put("/key/{category}/{key_name}")
def update_setting_by_key(
    category: str,
    key_name: str,
    setting_update: SystemSettingUpdate,
    current_user: User = Depends(get_current_admin),
    session: Session = Depends(get_session)
):
    """更新单个设置（需要管理员权限）"""
    statement = select(SystemSetting).where(
        SystemSetting.category == category,
        SystemSetting.key_name == key_name
    )
    setting = session.exec(statement).first()
    if not setting:
        raise HTTPException(status_code=404, detail="设置不存在")

    if not setting.is_editable:
        raise HTTPException(status_code=400, detail="该设置不可编辑")

    # 更新设置
    for field, value in setting_update.dict(exclude_unset=True).items():
        setattr(setting, field, value)

    session.add(setting)
    session.commit()
    session.refresh(setting)

    return {"message": "设置更新成功", "setting": setting}


@router.post("/batch-update")
def batch_update_settings(
    batch_update: SystemSettingBatchUpdate,
    current_user: User = Depends(get_current_admin),
    session: Session = Depends(get_session)
):
    """批量更新设置（需要管理员权限）"""
    updated_count = 0

    for setting_data in batch_update.settings:
        category = setting_data.get("category")
        key_name = setting_data.get("key_name")
        key_value = setting_data.get("key_value")

        if not all([category, key_name]):
            continue

        statement = select(SystemSetting).where(
            SystemSetting.category == category,
            SystemSetting.key_name == key_name
        )
        setting = session.exec(statement).first()

        if setting and setting.is_editable:
            setting.key_value = key_value
            session.add(setting)
            updated_count += 1

    session.commit()
    return {"message": f"批量更新成功，共更新 {updated_count} 个设置"}


@router.get("/ai/config", response_model=AISettingConfig)
def get_ai_config(
    session: Session = Depends(get_session)
) -> AISettingConfig:
    """获取AI配置"""
    try:
        statement = select(SystemSetting).where(SystemSetting.category == "ai").order_by(SystemSetting.sort_order)
        settings = session.exec(statement).all()

        if not settings:
            raise HTTPException(status_code=404, detail="AI配置不存在")

        # 构建AI配置
        ai_config = {}
        for setting in settings:
            value = setting.key_value

            # 根据类型转换值
            if setting.key_type == "number":
                # 检查是否是浮点数
                if '.' in str(value):
                    value = float(value) if value else 0.0
                else:
                    value = int(value) if value else 0
            elif setting.key_type == "boolean":
                value = value.lower() == "true" if value else False
            elif setting.key_type == "json":
                try:
                    value = json.loads(value) if value else {}
                except json.JSONDecodeError:
                    value = {}

            ai_config[setting.key_name] = value

        return AISettingConfig(**ai_config)
    except Exception as e:
        print(f"Error in get_ai_config: {e}")
        raise HTTPException(status_code=500, detail=f"获取AI配置失败: {str(e)}")


@router.put("/ai/config")
def update_ai_config(
    ai_config: AISettingConfig,
    current_user: User = Depends(get_current_admin),
    session: Session = Depends(get_session)
):
    """更新AI配置（需要管理员权限）"""
    updated_count = 0

    for field, value in ai_config.dict().items():
        statement = select(SystemSetting).where(
            SystemSetting.category == "ai",
            SystemSetting.key_name == field
        )
        setting = session.exec(statement).first()

        if setting and setting.is_editable:
            # 根据类型转换值
            if setting.key_type == "number":
                setting.key_value = str(value)
            elif setting.key_type == "boolean":
                setting.key_value = str(value).lower()
            else:
                setting.key_value = str(value)

            session.add(setting)
            updated_count += 1

    session.commit()
    return {"message": f"AI配置更新成功，共更新 {updated_count} 个设置"}


@router.post("/ai/test-connection")
async def test_ai_connection(
    ai_config: AISettingConfig,
    current_user: User = Depends(get_current_admin)
):
    """测试AI连接"""
    try:
        import aiohttp
        import ssl

        if not ai_config.api_key:
            return {
                "success": False,
                "message": "API密钥不能为空"
            }

        # 构建请求数据
        messages = [
            {
                "role": "user",
                "content": ai_config.prompt_template.replace("{keywords}", "AI,机器学习,深度学习")
            }
        ]

        headers = {
            "Authorization": f"Bearer {ai_config.api_key}",
            "Content-Type": "application/json"
        }

        data = {
            "model": ai_config.model,
            "messages": messages,
            "max_tokens": ai_config.max_tokens,
            "temperature": ai_config.temperature
        }

        # 创建SSL上下文（禁用验证）
        ssl_context = ssl.create_default_context()
        ssl_context.check_hostname = False
        ssl_context.verify_mode = ssl.CERT_NONE

        connector = aiohttp.TCPConnector(ssl=ssl_context)

        async with aiohttp.ClientSession(connector=connector) as session:
            url = f"{ai_config.base_url}/chat/completions"
            async with session.post(url, headers=headers, json=data) as response:
                if response.status == 200:
                    result = await response.json()
                    return {
                        "success": True,
                        "message": "AI连接测试成功",
                        "response": result.get("choices", [{}])[0].get("message", {}).get("content", "")
                    }
                else:
                    error_text = await response.text()
                    return {
                        "success": False,
                        "message": f"AI API返回错误: {response.status}",
                        "response": error_text
                    }

    except Exception as e:
        return {
            "success": False,
            "message": f"连接测试失败: {str(e)}"
        }


@router.get("/public/{category}", response_model=List[SystemSettingRead])
def get_public_settings(
    category: str,
    session: Session = Depends(get_session)
) -> List[SystemSettingRead]:
    """获取公开设置"""
    statement = select(SystemSetting).where(
        SystemSetting.category == category,
        SystemSetting.is_public == True
    ).order_by(SystemSetting.sort_order)
    settings = session.exec(statement).all()
    return settings


@router.delete("/{setting_id}")
def delete_setting(
    setting_id: int,
    current_user: User = Depends(get_current_admin),
    session: Session = Depends(get_session)
):
    """删除系统设置（需要管理员权限）"""
    setting = session.get(SystemSetting, setting_id)
    if not setting:
        raise HTTPException(status_code=404, detail="设置不存在")

    if not setting.is_editable:
        raise HTTPException(status_code=400, detail="该设置不可删除")

    session.delete(setting)
    session.commit()
    return {"message": "设置删除成功"}

"""
随机图片搜索服务
支持根据标签搜索相关图片并下载保存到本地
"""
import os
import random
import uuid
import urllib.request
import urllib.parse
from datetime import datetime
from typing import List, Optional, Dict, Any

from app.core.config import settings
from app.db.session import get_session
from app.models.attachment import Attachment, AttachmentCreate
from app.models.system import SystemDefault


class ImageSearchService:
    """图片搜索服务"""

    def __init__(self):
        # Unsplash API配置
        self.unsplash_access_key = getattr(
            settings, 'unsplash_access_key', 'demo_key'
        )
        self.unsplash_base_url = "https://api.unsplash.com"

        # 从系统配置加载设置
        self._load_config_from_db()

        # 备用图片源（如果Unsplash不可用）
        self.fallback_images = {
            "二次元": [
                "https://picsum.photos/800/600?random=1",
                "https://picsum.photos/800/600?random=2",
            ],
            "风景": [
                "https://picsum.photos/800/600?random=3",
                "https://picsum.photos/800/600?random=4",
            ],
            "美女": [
                "https://picsum.photos/800/600?random=5",
                "https://picsum.photos/800/600?random=6",
            ],
            "科技": [
                "https://picsum.photos/800/600?random=7",
                "https://picsum.photos/800/600?random=8",
            ],
            "默认": [
                "https://picsum.photos/800/600?random=9",
                "https://picsum.photos/800/600?random=10",
            ]
        }

        # 默认标签映射（中文到英文）
        self.default_tag_mapping = {
            "二次元": "anime",
            "风景": "landscape",
            "美女": "portrait",
            "科技": "technology",
            "编程": "programming",
            "代码": "code",
            "开发": "development",
            "设计": "design",
            "艺术": "art",
            "自然": "nature",
            "城市": "city",
            "建筑": "architecture",
            "抽象": "abstract",
            "商务": "business",
            "教育": "education",
            "医疗": "medical",
            "运动": "sports",
            "音乐": "music",
            "食物": "food",
            "旅行": "travel"
        }

        # 从配置加载的标签映射
        self.tag_mapping = self.default_tag_mapping.copy()

        # 配置参数
        self.default_tags = ["nature", "landscape"]
        self.default_orientation = "landscape"
        self.column_cover_tags = ["minimal", "modern", "geometric"]
        self.search_count = 10
        self.enable_unsplash = True
        self.auto_generate_tags = True
        self.tag_mapping_rules = ""

    def _load_config_from_db(self):
        """从数据库加载配置"""
        try:
            with next(get_session()) as session:
                # 查询ImageSearch分类的所有配置
                configs = session.query(SystemDefault).filter(
                    SystemDefault.category == 'ImageSearch'
                ).all()

                for config in configs:
                    key = config.key_name
                    value = config.key_value

                    # 根据数据类型转换值
                    if config.data_type == 'boolean':
                        value = value.lower() in ('true', '1', 'yes')
                    elif config.data_type == 'integer':
                        try:
                            value = int(value)
                        except ValueError:
                            continue
                    elif config.data_type == 'json':
                        try:
                            import json
                            value = json.loads(value)
                        except (json.JSONDecodeError, ValueError):
                            continue

                    # 设置配置值
                    if hasattr(self, key):
                        setattr(self, key, value)

                    # 特殊处理标签字段 - 支持中文逗号分割
                    if key in ['default_tags', 'column_cover_tags'] and value:
                        # 分割标签字符串，支持英文逗号和中文逗号
                        import re
                        tags = [
                            tag.strip()
                            for tag in re.split(r'[,，]', value)
                            if tag.strip()
                        ]
                        setattr(self, key, tags)

                    # 特殊处理标签映射规则
                    if key == 'tag_mapping_rules' and value:
                        self._parse_tag_mapping_rules(value)
        except Exception as e:
            print(f"加载图片搜索配置失败: {e}")
            # 使用默认配置

    def _parse_tag_mapping_rules(self, rules_text: str):
        """解析标签映射规则"""
        try:
            lines = rules_text.strip().split('\n')
            for line in lines:
                line = line.strip()
                if ':' in line:
                    keyword, tags = line.split(':', 1)
                    keyword = keyword.strip()
                    # 支持中文逗号分割
                    import re
                    tag_list = [
                        tag.strip()
                        for tag in re.split(r'[,，]', tags)
                        if tag.strip()
                    ]
                    self.tag_mapping[keyword] = (
                        tag_list[0] if tag_list else keyword
                    )
        except Exception as e:
            print(f"解析标签映射规则失败: {e}")

    def search_images(
        self,
        tags: List[str] = None,
        count: int = None,
        orientation: str = None
    ) -> List[Dict[str, Any]]:
        """
        搜索图片

        Args:
            tags: 搜索标签列表，如果为None则使用默认标签
            count: 返回图片数量，如果为None则使用配置的默认值
            orientation: 图片方向 (landscape, portrait, squarish)，如果为None则使用配置的默认值

        Returns:
            图片信息列表
        """
        try:
            # 使用配置的默认值
            if tags is None:
                tags = self.default_tags
            if count is None:
                count = self.search_count
            if orientation is None:
                orientation = self.default_orientation

            # 转换中文标签为英文
            english_tags = []
            for tag in tags:
                if tag in self.tag_mapping:
                    english_tags.append(self.tag_mapping[tag])
                else:
                    english_tags.append(tag)

            # 构建搜索查询
            query = " ".join(english_tags) if english_tags else "nature"

            # 尝试使用Unsplash API（如果启用）
            images = []
            if self.enable_unsplash:
                images = self._search_unsplash(query, count, orientation)

            if not images:
                # 如果Unsplash失败或未启用，使用备用图片
                images = self._get_fallback_images(tags, count)

            return images

        except Exception as e:
            print(f"图片搜索失败: {e}")
            fallback_tags = tags or self.default_tags
            fallback_count = count or self.search_count
            return self._get_fallback_images(fallback_tags, fallback_count)

    def _search_unsplash(
        self,
        query: str,
        count: int,
        orientation: str
    ) -> List[Dict[str, Any]]:
        """使用Unsplash API搜索图片"""
        try:
            # 由于网络限制，暂时跳过Unsplash API，直接返回空列表
            # 实际部署时可以配置正确的API密钥和网络环境
            print("Unsplash API暂时不可用，使用备用图片源")
            return []

        except Exception as e:
            print(f"Unsplash搜索失败: {e}")
            return []

    def _get_fallback_images(
        self, tags: List[str], count: int
    ) -> List[Dict[str, Any]]:
        """获取备用图片"""
        # 根据标签选择对应的备用图片
        selected_images = []

        for tag in tags:
            if tag in self.fallback_images:
                selected_images.extend(self.fallback_images[tag])

        # 如果没有匹配的标签，使用默认图片
        if not selected_images:
            selected_images = self.fallback_images["默认"]

        # 随机选择图片
        random.shuffle(selected_images)
        selected_images = selected_images[:count]

        # 格式化返回数据
        images = []
        for i, url in enumerate(selected_images):
            images.append({
                "id": f"fallback_{i}",
                "url": url,
                "download_url": url,
                "description": f"备用图片 - {', '.join(tags)}",
                "alt_description": f"Random image for {', '.join(tags)}",
                "width": 800,
                "height": 600,
                "author": "Picsum Photos",
                "author_url": "https://picsum.photos/",
                "source": "fallback"
            })

        return images

    def download_and_save_image(
        self,
        image_info: Dict[str, Any],
        user_id: int = 1
    ) -> Optional[Attachment]:
        """
        下载图片并保存为附件

        Args:
            image_info: 图片信息
            user_id: 用户ID

        Returns:
            保存的附件对象
        """
        try:
            # 下载图片
            image_data = self._download_image(image_info["download_url"])
            if not image_data:
                return None

            # 生成文件名
            file_extension = self._get_file_extension(
                image_info["download_url"]
            )
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            random_id = str(uuid.uuid4())[:8]
            filename = f"{timestamp}_{random_id}{file_extension}"

            # 保存到本地
            upload_dir = "uploads/images"
            os.makedirs(upload_dir, exist_ok=True)
            file_path = os.path.join(upload_dir, filename)

            with open(file_path, 'wb') as f:
                f.write(image_data)
            # 计算文件大小
            file_size = len(image_data)

            # 创建附件记录
            desc = image_info.get('description', 'random_image')
            attachment_data = AttachmentCreate(
                filename=filename,
                original_name=f"{desc}{file_extension}",
                file_path=file_path,
                file_url=f"/{file_path}",
                file_size=file_size,
                file_type=f"image/{file_extension[1:]}",
                file_extension=file_extension,
                uploaded_by=user_id,
                description=f"自动生成 - {desc}",
                tags=f"source:{image_info['source']},"
                     f"author:{image_info['author']}"
            )

            # 保存到数据库
            with next(get_session()) as session:
                attachment = Attachment.model_validate(attachment_data)
                session.add(attachment)
                session.commit()
                session.refresh(attachment)
                return attachment

        except Exception as e:
            print(f"下载保存图片失败: {e}")
            return None

    def _download_image(self, url: str) -> Optional[bytes]:
        """下载图片数据"""
        try:
            import ssl
            # 创建不验证SSL证书的上下文
            ssl_context = ssl.create_default_context()
            ssl_context.check_hostname = False
            ssl_context.verify_mode = ssl.CERT_NONE

            with urllib.request.urlopen(url, context=ssl_context) as response:
                if response.status == 200:
                    return response.read()
                else:
                    print(f"下载图片失败: {response.status}")
                    return None
        except Exception as e:
            print(f"下载图片异常: {e}")
            return None

    def _get_file_extension(self, url: str) -> str:
        """从URL获取文件扩展名"""
        parsed_url = urllib.parse.urlparse(url)
        path = parsed_url.path.lower()

        if path.endswith('.jpg') or path.endswith('.jpeg'):
            return '.jpg'
        elif path.endswith('.png'):
            return '.png'
        elif path.endswith('.webp'):
            return '.webp'
        elif path.endswith('.gif'):
            return '.gif'
        else:
            return '.jpg'  # 默认使用jpg

    def get_random_cover_image(
        self,
        tags: List[str] = None,
        user_id: int = 1
    ) -> Optional[str]:
        """
        获取随机封面图片URL

        Args:
            tags: 搜索标签，如果为None则使用专栏封面专用标签
            user_id: 用户ID

        Returns:
            图片URL
        """
        try:
            # 如果没有提供标签，使用专栏封面专用标签
            if tags is None:
                tags = self.column_cover_tags

            # 搜索图片
            images = self.search_images(tags, count=5)
            if not images:
                return None

            # 随机选择一张图片
            selected_image = random.choice(images)

            # 下载并保存
            attachment = self.download_and_save_image(selected_image, user_id)
            if attachment:
                return attachment.file_url
            else:
                return None

        except Exception as e:
            print(f"获取随机封面图片失败: {e}")
            return None

    def generate_tags_from_name(self, name: str) -> List[str]:
        """
        根据名称自动生成标签

        Args:
            name: 名称

        Returns:
            生成的标签列表
        """
        if not self.auto_generate_tags:
            return self.column_cover_tags

        generated_tags = []
        name_lower = name.lower()

        # 遍历标签映射规则
        for keyword, tag in self.tag_mapping.items():
            if keyword in name_lower:
                generated_tags.append(tag)

        # 如果没有匹配的标签，使用默认标签
        if not generated_tags:
            generated_tags = self.column_cover_tags

        return generated_tags


# 创建全局实例
image_search_service = ImageSearchService()

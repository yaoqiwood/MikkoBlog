import asyncio
import aiohttp
from datetime import datetime, date
from typing import List, Dict, Optional, Tuple
from sqlmodel import Session, select, func
from app.db.session import get_session
from app.models.tagCloud import (
    TagCloud, TagCloudCreate, TagCloudUpdate, TagCloudFetchHistory,
    TagSize, TagSource, FetchStatus
)
from app.models.system import SystemDefault
import logging

logger = logging.getLogger(__name__)


class TagCloudService:
    def __init__(self, session: Session):
        self.session = session

    async def fetch_tags_from_ai(self, keywords: List[str] = None) -> List[Dict]:
        """从AI大模型获取标签"""
        try:
            # 获取AI设置
            ai_settings = await self.get_ai_settings()
            if not ai_settings:
                logger.error("AI设置未配置")
                return []

            # 构建提示词
            keywords_text = ", ".join(keywords) if keywords else "技术,编程,开发"
            prompt = ai_settings["ai_prompt_template"].replace("{keywords}", keywords_text)

            # 构建请求数据
            messages = [
                {
                    "role": "user",
                    "content": prompt
                }
            ]

            headers = {
                "Authorization": f"Bearer {ai_settings['ai_api_key']}",
                "Content-Type": "application/json"
            }

            data = {
                "model": ai_settings["ai_model"],
                "messages": messages,
                "max_tokens": int(ai_settings["ai_max_tokens"]),
                "temperature": float(ai_settings["ai_temperature"])
            }

            # 创建SSL上下文
            ssl_context = ssl.create_default_context()
            ssl_context.check_hostname = False
            ssl_context.verify_mode = ssl.CERT_NONE

            connector = aiohttp.TCPConnector(ssl=ssl_context)

            async with aiohttp.ClientSession(connector=connector) as session:
                url = f"{ai_settings['ai_base_url']}/chat/completions"
                async with session.post(url, headers=headers, json=data) as response:
                    if response.status == 200:
                        result = await response.json()
                        content = result.get("choices", [{}])[0].get("message", {}).get("content", "")

                        # 解析JSON响应
                        try:
                            # 尝试提取JSON部分
                            import re
                            json_match = re.search(r'\[.*\]', content, re.DOTALL)
                            if json_match:
                                json_str = json_match.group()
                                tags_data = json.loads(json_str)

                                # 转换为标准格式
                                tags = []
                                for tag_data in tags_data:
                                    if isinstance(tag_data, dict) and "name" in tag_data:
                                        tags.append({
                                            "name": tag_data["name"],
                                            "count": tag_data.get("count", 1),
                                            "category": tag_data.get("category", "ai_generated"),
                                            "size": self.get_size_by_count(tag_data.get("count", 1)),
                                            "color": self.get_color_by_category(tag_data.get("category", "ai_generated")),
                                            "source": "ai",
                                            "is_active": True
                                        })

                                logger.info(f"AI generated {len(tags)} tags")
                                return tags
                            else:
                                logger.error("AI响应中未找到有效的JSON格式")
                                return []
                        except json.JSONDecodeError as e:
                            logger.error(f"解析AI响应JSON失败: {e}")
                            return []
                    else:
                        error_text = await response.text()
                        logger.error(f"AI API请求失败: {response.status}, {error_text}")
                        return []

        except Exception as e:
            logger.error(f"从AI获取标签失败: {e}")
            return []

    async def get_ai_settings(self) -> Dict:
        """获取AI设置"""
        try:
            statement = select(SystemDefault).where(SystemDefault.category == "AISettings")
            settings = self.session.exec(statement).all()

            ai_settings = {}
            for setting in settings:
                ai_settings[setting.key_name] = setting.key_value

            return ai_settings
        except Exception as e:
            logger.error(f"获取AI设置失败: {e}")
            return {}

    def get_size_by_count(self, count: int) -> str:
        """根据使用次数确定标签大小"""
        if count >= 100:
            return "large"
        elif count >= 50:
            return "medium"
        else:
            return "small"

    def get_color_by_category(self, category: str) -> str:
        """根据分类确定标签颜色"""
        color_map = {
            "programming": "#ff6b6b",
            "ai_generated": "#4ecdc4",
            "web": "#45b7d1",
            "mobile": "#96ceb4",
            "data": "#feca57",
            "cloud": "#ff9ff3",
            "security": "#ff6348",
            "devops": "#5f27cd"
        }
        return color_map.get(category, "#95a5a6")

    async def fetch_trending_tags_from_github(self) -> List[Dict]:
        """从GitHub获取热门标签"""
        try:
            import ssl
            ssl_context = ssl.create_default_context()
            ssl_context.check_hostname = False
            ssl_context.verify_mode = ssl.CERT_NONE

            connector = aiohttp.TCPConnector(ssl=ssl_context)
            async with aiohttp.ClientSession(connector=connector) as session:
                # GitHub API获取热门仓库的语言标签
                url = "https://api.github.com/search/repositories"
                params = {
                    "q": "stars:>1000",
                    "sort": "stars",
                    "order": "desc",
                    "per_page": 100
                }

                async with session.get(url, params=params) as response:
                    if response.status == 200:
                        data = await response.json()
                        languages = {}

                        for repo in data.get("items", []):
                            lang = repo.get("language")
                            if lang:
                                languages[lang] = languages.get(lang, 0) + 1

                        # 转换为标签格式
                        tags = []
                        for lang, count in sorted(languages.items(), key=lambda x: x[1], reverse=True)[:20]:
                            tags.append({
                                "name": lang,
                                "count": count,
                                "category": "programming",
                                "source": "github"
                            })

                        return tags
                    else:
                        logger.error(f"GitHub API error: {response.status}")
                        return []
        except Exception as e:
            logger.error(f"Error fetching from GitHub: {e}")
            return []

    async def fetch_trending_tags_from_stackoverflow(self) -> List[Dict]:
        """从Stack Overflow获取热门标签"""
        try:
            import ssl
            ssl_context = ssl.create_default_context()
            ssl_context.check_hostname = False
            ssl_context.verify_mode = ssl.CERT_NONE

            connector = aiohttp.TCPConnector(ssl=ssl_context)
            async with aiohttp.ClientSession(connector=connector) as session:
                # Stack Overflow API获取热门标签
                url = "https://api.stackexchange.com/2.3/tags"
                params = {
                    "order": "desc",
                    "sort": "popular",
                    "site": "stackoverflow",
                    "pagesize": 50
                }

                async with session.get(url, params=params) as response:
                    if response.status == 200:
                        data = await response.json()
                        tags = []

                        for item in data.get("items", []):
                            tags.append({
                                "name": item["name"],
                                "count": item["count"],
                                "category": "programming",
                                "source": "stackoverflow"
                            })

                        return tags
                    else:
                        logger.error(f"Stack Overflow API error: {response.status}")
                        return []
        except Exception as e:
            logger.error(f"Error fetching from Stack Overflow: {e}")
            return []

    async def fetch_trending_tags_from_reddit(self) -> List[Dict]:
        """从Reddit获取热门标签"""
        try:
            import ssl
            ssl_context = ssl.create_default_context()
            ssl_context.check_hostname = False
            ssl_context.verify_mode = ssl.CERT_NONE

            connector = aiohttp.TCPConnector(ssl=ssl_context)
            async with aiohttp.ClientSession(connector=connector) as session:
                # Reddit API获取热门帖子标签
                url = "https://www.reddit.com/r/programming/hot.json"
                params = {"limit": 100}

                async with session.get(url, params=params) as response:
                    if response.status == 200:
                        data = await response.json()
                        tags = {}

                        for post in data.get("data", {}).get("children", []):
                            post_data = post.get("data", {})
                            # 从标题中提取标签
                            title = post_data.get("title", "").lower()

                            # 简单的关键词提取
                            keywords = ["python", "javascript", "react", "vue", "node", "css", "html", "java", "c++", "go", "rust", "typescript"]
                            for keyword in keywords:
                                if keyword in title:
                                    tags[keyword] = tags.get(keyword, 0) + 1

                        # 转换为标签格式
                        result = []
                        for tag, count in sorted(tags.items(), key=lambda x: x[1], reverse=True)[:15]:
                            result.append({
                                "name": tag.title(),
                                "count": count,
                                "category": "programming",
                                "source": "reddit"
                            })

                        return result
                    else:
                        logger.error(f"Reddit API error: {response.status}")
                        return []
        except Exception as e:
            logger.error(f"Error fetching from Reddit: {e}")
            return []

    def determine_tag_size(self, count: int) -> TagSize:
        """根据使用次数确定标签大小"""
        if count >= 50:
            return TagSize.LARGE
        elif count >= 20:
            return TagSize.MEDIUM
        else:
            return TagSize.SMALL

    def determine_tag_color(self, category: str) -> str:
        """根据分类确定标签颜色"""
        color_map = {
            "frontend": "#4fc08d",
            "backend": "#3776ab",
            "database": "#4479a1",
            "devops": "#2496ed",
            "programming": "#f7df1e",
            "tools": "#f05032",
            "general": "#ff6b6b"
        }
        return color_map.get(category, "#ff6b6b")

    async def update_tag_cloud(self, tags: List[Dict], source: str, clear_existing: bool = False) -> Tuple[int, int]:
        """更新标签云数据"""
        new_tags = 0
        updated_tags = 0

        # 如果需要清空现有标签
        if clear_existing:
            # 删除所有自动获取的标签
            statement = select(TagCloud).where(TagCloud.source == TagSource.AUTO)
            existing_auto_tags = self.session.exec(statement).all()
            for tag in existing_auto_tags:
                self.session.delete(tag)
            self.session.commit()
            logger.info(f"Cleared {len(existing_auto_tags)} existing auto-generated tags")

        for tag_data in tags:
            # 检查标签是否已存在
            statement = select(TagCloud).where(TagCloud.name == tag_data["name"])
            existing_tag = self.session.exec(statement).first()

            if existing_tag:
                # 更新现有标签
                existing_tag.count = max(existing_tag.count, tag_data["count"])
                existing_tag.size = self.determine_tag_size(existing_tag.count)
                existing_tag.color = self.determine_tag_color(tag_data.get("category", "general"))
                existing_tag.source = TagSource.AUTO
                existing_tag.last_fetched_at = datetime.utcnow()
                existing_tag.updated_at = datetime.utcnow()
                updated_tags += 1
            else:
                # 创建新标签
                new_tag = TagCloud(
                    name=tag_data["name"],
                    count=tag_data["count"],
                    size=self.determine_tag_size(tag_data["count"]),
                    color=self.determine_tag_color(tag_data.get("category", "general")),
                    category=tag_data.get("category", "general"),
                    source=TagSource.AUTO,
                    is_active=True,
                    last_fetched_at=datetime.utcnow()
                )
                self.session.add(new_tag)
                new_tags += 1

        self.session.commit()
        return new_tags, updated_tags

    async def fetch_and_update_tags(self) -> Dict:
        """获取并更新标签云"""
        fetch_date = date.today()
        total_tags = 0
        new_tags = 0
        updated_tags = 0
        status = FetchStatus.SUCCESS
        error_message = None

        try:
            logger.info("Starting AI-based tag fetch...")

            # 从AI获取标签
            result = await self.fetch_tags_from_ai()

            if result:
                tags_count = len(result)
                total_tags += tags_count
                logger.info(f"AI generated {tags_count} tags")

                new_count, updated_count = await self.update_tag_cloud(result, "ai", clear_existing=True)
                new_tags += new_count
                updated_tags += updated_count
                logger.info(f"AI tags: {new_count} new, {updated_count} updated")
            else:
                logger.warning("AI did not generate any tags")

            # 记录获取历史
            history = TagCloudFetchHistory(
                fetch_date=fetch_date,
                source="multiple",
                total_tags=total_tags,
                new_tags=new_tags,
                updated_tags=updated_tags,
                status=status
            )
            self.session.add(history)
            self.session.commit()

            logger.info(f"Tag cloud updated: {new_tags} new, {updated_tags} updated")

        except Exception as e:
            logger.error(f"Error in fetch_and_update_tags: {e}")
            status = FetchStatus.FAILED
            error_message = str(e)

            # 记录失败历史
            history = TagCloudFetchHistory(
                fetch_date=fetch_date,
                source="multiple",
                total_tags=total_tags,
                new_tags=new_tags,
                updated_tags=updated_tags,
                status=status,
                error_message=error_message
            )
            self.session.add(history)
            self.session.commit()

        return {
            "fetch_date": fetch_date,
            "total_tags": total_tags,
            "new_tags": new_tags,
            "updated_tags": updated_tags,
            "status": status,
            "error_message": error_message
        }

    async def fetch_tags_by_keywords(self, keywords):
        """根据关键词获取标签"""
        logger.info(f"Fetching tags by keywords: {keywords}")

        fetch_date = date.today()
        total_tags = 0
        new_tags = 0
        updated_tags = 0
        status = FetchStatus.SUCCESS
        error_message = None

        try:
            # 使用AI根据关键词生成标签
            result = await self.fetch_tags_from_ai(keywords)

            if result:
                tags_count = len(result)
                total_tags += tags_count
                logger.info(f"AI generated {tags_count} tags for keywords: {keywords}")

                new_count, updated_count = await self.update_tag_cloud(result, "ai_keywords", clear_existing=True)
                new_tags += new_count
                updated_tags += updated_count
                logger.info(f"AI keyword tags: {new_count} new, {updated_count} updated")
            else:
                logger.warning(f"AI did not generate any tags for keywords: {keywords}")

            # 记录获取历史
            history = TagCloudFetchHistory(
                fetch_date=fetch_date,
                source=f"ai_keywords_{','.join(keywords)}",
                total_tags=total_tags,
                new_tags=new_tags,
                updated_tags=updated_tags,
                status=status
            )
            self.session.add(history)
            self.session.commit()

            logger.info(f"Custom search completed: {new_tags} new, {updated_tags} updated")

        except Exception as e:
            logger.error(f"Error in fetch_tags_by_keywords: {e}")
            status = FetchStatus.FAILED
            error_message = str(e)

            # 记录失败历史
            history = TagCloudFetchHistory(
                fetch_date=fetch_date,
                source=f"custom_search_{','.join(keywords)}",
                total_tags=0,
                new_tags=0,
                updated_tags=0,
                status=status,
                error_message=error_message
            )
            self.session.add(history)
            self.session.commit()

        return {
            "fetch_date": fetch_date,
            "total_tags": total_tags,
            "new_tags": new_tags,
            "updated_tags": updated_tags,
            "status": status,
            "error_message": error_message
        }

    async def search_tags_by_keyword(self, keyword, source):
        """根据关键词从指定源搜索标签"""
        tags = []

        try:
            if source == "github":
                # 搜索GitHub仓库
                url = f"https://api.github.com/search/repositories?q={keyword}&sort=stars&order=desc&per_page=50"
                headers = {"Accept": "application/vnd.github.v3+json"}

                import ssl
                ssl_context = ssl.create_default_context()
                ssl_context.check_hostname = False
                ssl_context.verify_mode = ssl.CERT_NONE

                connector = aiohttp.TCPConnector(ssl=ssl_context)
                async with aiohttp.ClientSession(connector=connector) as client_session:
                    async with client_session.get(url, headers=headers) as response:
                        if response.status == 200:
                            data = await response.json()
                            for item in data.get("items", []):
                                # 提取语言标签
                                lang = item.get("language")
                                if lang and lang not in ["null", "None"]:
                                    tags.append({
                                        "name": lang,
                                        "source": TagSource.trending,
                                        "category": self.get_category_by_keyword(keyword)
                                    })

                                # 提取主题标签
                                topics = item.get("topics", [])
                                for topic in topics[:5]:  # 限制数量
                                    tags.append({
                                        "name": topic,
                                        "source": TagSource.trending,
                                        "category": self.get_category_by_keyword(keyword)
                                    })

            elif source == "stackoverflow":
                # 搜索Stack Overflow问题
                url = f"https://api.stackexchange.com/2.3/questions?order=desc&sort=votes&tagged={keyword}&site=stackoverflow&pagesize=50"

                import ssl
                ssl_context = ssl.create_default_context()
                ssl_context.check_hostname = False
                ssl_context.verify_mode = ssl.CERT_NONE

                connector = aiohttp.TCPConnector(ssl=ssl_context)
                async with aiohttp.ClientSession(connector=connector) as client_session:
                    async with client_session.get(url) as response:
                        if response.status == 200:
                            data = await response.json()
                            for item in data.get("items", []):
                                tags_list = item.get("tags", [])
                                for tag in tags_list[:3]:  # 限制数量
                                    tags.append({
                                        "name": tag,
                                        "source": TagSource.trending,
                                        "category": self.get_category_by_keyword(keyword)
                                    })

            elif source == "reddit":
                # 搜索Reddit帖子（使用Reddit API或模拟搜索）
                # 这里使用模拟数据，实际应用中需要Reddit API
                mock_tags = [
                    keyword + "_discussion",
                    keyword + "_community",
                    keyword + "_tips"
                ]
                for tag in mock_tags:
                    tags.append({
                        "name": tag,
                        "source": TagSource.trending,
                        "category": self.get_category_by_keyword(keyword)
                    })

        except Exception as e:
            logger.error(f"Error searching {source} for keyword {keyword}: {e}")

        return tags

    def get_category_by_keyword(self, keyword):
        """根据关键词确定标签分类"""
        keyword_lower = keyword.lower()

        if any(word in keyword_lower for word in ["ai", "artificial", "intelligence", "machine", "learning", "deep", "neural"]):
            return "ai"
        elif any(word in keyword_lower for word in ["web", "frontend", "backend", "fullstack", "react", "vue", "angular"]):
            return "web"
        elif any(word in keyword_lower for word in ["mobile", "ios", "android", "flutter", "react-native"]):
            return "mobile"
        elif any(word in keyword_lower for word in ["data", "database", "sql", "nosql", "analytics"]):
            return "data"
        elif any(word in keyword_lower for word in ["devops", "docker", "kubernetes", "ci", "cd", "deploy"]):
            return "devops"
        elif any(word in keyword_lower for word in ["game", "unity", "unreal", "gaming"]):
            return "gaming"
        else:
            return "general"

    def get_active_tags(self, limit: int = 50) -> List[TagCloud]:
        """获取活跃标签"""
        statement = (
            select(TagCloud)
            .where(TagCloud.is_active.is_(True))
            .order_by(TagCloud.count.desc())
            .limit(limit)
        )
        return list(self.session.exec(statement))

    def get_fetch_history(self, limit: int = 30) -> List[TagCloudFetchHistory]:
        """获取获取历史"""
        statement = (
            select(TagCloudFetchHistory)
            .order_by(TagCloudFetchHistory.fetch_date.desc())
            .limit(limit)
        )
        return list(self.session.exec(statement))

    def create_manual_tag(self, tag_data: TagCloudCreate) -> TagCloud:
        """创建手动标签"""
        tag = TagCloud(**tag_data.dict())
        self.session.add(tag)
        self.session.commit()
        self.session.refresh(tag)
        return tag

    def update_manual_tag(self, tag_id: int, tag_data: TagCloudUpdate) -> Optional[TagCloud]:
        """更新手动标签"""
        statement = select(TagCloud).where(TagCloud.id == tag_id)
        tag = self.session.exec(statement).first()

        if tag:
            tag_data_dict = tag_data.dict(exclude_unset=True)
            for key, value in tag_data_dict.items():
                setattr(tag, key, value)
            tag.updated_at = datetime.utcnow()
            self.session.add(tag)
            self.session.commit()
            self.session.refresh(tag)

        return tag

    def delete_tag(self, tag_id: int) -> bool:
        """删除标签"""
        statement = select(TagCloud).where(TagCloud.id == tag_id)
        tag = self.session.exec(statement).first()

        if tag:
            self.session.delete(tag)
            self.session.commit()
            return True

        return False

    def toggle_tag_status(self, tag_id: int) -> Optional[TagCloud]:
        """切换标签状态"""
        statement = select(TagCloud).where(TagCloud.id == tag_id)
        tag = self.session.exec(statement).first()

        if tag:
            tag.is_active = not tag.is_active
            tag.updated_at = datetime.utcnow()
            self.session.add(tag)
            self.session.commit()
            self.session.refresh(tag)

        return tag

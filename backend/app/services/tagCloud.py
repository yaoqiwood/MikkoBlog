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
import logging

logger = logging.getLogger(__name__)


class TagCloudService:
    def __init__(self):
        self.session = next(get_session())

    async def fetch_trending_tags_from_github(self) -> List[Dict]:
        """从GitHub获取热门标签"""
        try:
            async with aiohttp.ClientSession() as session:
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
            async with aiohttp.ClientSession() as session:
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
            async with aiohttp.ClientSession() as session:
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

    async def update_tag_cloud(self, tags: List[Dict], source: str) -> Tuple[int, int]:
        """更新标签云数据"""
        new_tags = 0
        updated_tags = 0

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
            # 并行获取多个数据源
            tasks = [
                self.fetch_trending_tags_from_github(),
                self.fetch_trending_tags_from_stackoverflow(),
                self.fetch_trending_tags_from_reddit()
            ]

            results = await asyncio.gather(*tasks, return_exceptions=True)

            for i, result in enumerate(results):
                if isinstance(result, Exception):
                    logger.error(f"Error in task {i}: {result}")
                    continue

                if result:
                    source_name = ["github", "stackoverflow", "reddit"][i]
                    tags_count = len(result)
                    total_tags += tags_count

                    # 更新标签云
                    new_count, updated_count = await self.update_tag_cloud(result, source_name)
                    new_tags += new_count
                    updated_tags += updated_count

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
            # 根据关键词搜索相关标签
            all_tags = []

            for keyword in keywords:
                # 从GitHub搜索相关仓库
                github_tags = await self.search_tags_by_keyword(keyword, "github")
                all_tags.extend(github_tags)

                # 从Stack Overflow搜索相关问题
                so_tags = await self.search_tags_by_keyword(keyword, "stackoverflow")
                all_tags.extend(so_tags)

                # 从Reddit搜索相关讨论
                reddit_tags = await self.search_tags_by_keyword(keyword, "reddit")
                all_tags.extend(reddit_tags)

            # 去重并合并相同标签
            unique_tags = {}
            for tag in all_tags:
                name = tag["name"].lower()
                if name in unique_tags:
                    unique_tags[name]["count"] += tag["count"]
                else:
                    unique_tags[name] = tag

            final_tags = list(unique_tags.values())
            total_tags = len(final_tags)

            # 更新标签云
            new_count, updated_count = await self.update_tag_cloud(final_tags, "custom_search")
            new_tags = new_count
            updated_tags = updated_count

            # 记录获取历史
            history = TagCloudFetchHistory(
                fetch_date=fetch_date,
                source=f"custom_search_{','.join(keywords)}",
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

                async with aiohttp.ClientSession() as client_session:
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

                async with aiohttp.ClientSession() as client_session:
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

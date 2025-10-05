import asyncio
import schedule
import time
from datetime import datetime
from app.services.tagCloud import TagCloudService
import logging

logger = logging.getLogger(__name__)


class TagCloudScheduler:
    def __init__(self):
        self.tag_service = None  # 延迟初始化
        self.is_running = False
        self.scheduled_time = "02:00"  # 默认时间
        self.schedule_frequency = "daily"  # 默认频度：daily, weekly, hourly
        self.schedule_day = "monday"  # 周频度时的星期几
        self.search_keywords = []  # 自定义搜索关键词

    def _get_tag_service(self):
        """获取TagCloudService实例"""
        if self.tag_service is None:
            from app.db.session import get_session
            session = next(get_session())
            self.tag_service = TagCloudService(session)
        return self.tag_service

    async def daily_fetch_task(self):
        """每日标签获取任务"""
        logger.info("Starting daily tag cloud fetch task...")

        try:
            # 如果有自定义搜索关键词，使用自定义搜索
            if self.search_keywords:
                logger.info(f"Using custom search keywords: {self.search_keywords}")
                result = await self._get_tag_service().fetch_tags_by_keywords(self.search_keywords)
            else:
                # 使用默认的多源获取
                result = await self._get_tag_service().fetch_and_update_tags()

            logger.info(f"Daily fetch completed: {result}")
        except Exception as e:
            logger.error(f"Daily fetch failed: {e}")

    def run_daily_fetch(self):
        """运行每日获取任务（同步包装器）"""
        asyncio.run(self.daily_fetch_task())

    def start_scheduler(self):
        """启动定时任务调度器"""
        if self.is_running:
            logger.warning("Scheduler is already running")
            return

        self.is_running = True
        logger.info("Starting tag cloud scheduler...")

        # 根据频度设置调度
        if self.schedule_frequency == "hourly":
            schedule.every().hour.at(f":{self.scheduled_time.split(':')[1]}").do(self.run_daily_fetch)
            logger.info(f"Tag cloud scheduler started. Next run: every hour at minute {self.scheduled_time.split(':')[1]}")
        elif self.schedule_frequency == "weekly":
            # 将星期几转换为数字
            day_map = {
                "monday": 0, "tuesday": 1, "wednesday": 2, "thursday": 3,
                "friday": 4, "saturday": 5, "sunday": 6
            }
            day_num = day_map.get(self.schedule_day.lower(), 0)
            schedule.every().week.at(self.scheduled_time).do(self.run_daily_fetch)
            logger.info(f"Tag cloud scheduler started. Next run: weekly on {self.schedule_day} at {self.scheduled_time}")
        else:  # daily
            schedule.every().day.at(self.scheduled_time).do(self.run_daily_fetch)
            logger.info(f"Tag cloud scheduler started. Next run: daily at {self.scheduled_time}")

        # 运行调度器
        while self.is_running:
            schedule.run_pending()
            time.sleep(60)  # 每分钟检查一次

    def stop_scheduler(self):
        """停止定时任务调度器"""
        self.is_running = False
        schedule.clear()
        logger.info("Tag cloud scheduler stopped")

    def update_schedule_time(self, new_time):
        """更新调度时间"""
        if self.is_running:
            # 如果调度器正在运行，需要重启
            self.stop_scheduler()
            self.scheduled_time = new_time
            self.start_scheduler()
        else:
            self.scheduled_time = new_time

        logger.info(f"Schedule time updated to: {new_time}")

    def update_schedule_config(self, frequency=None, time=None, day=None):
        """更新调度配置"""
        if self.is_running:
            # 如果调度器正在运行，需要重启
            self.stop_scheduler()

        if frequency is not None:
            self.schedule_frequency = frequency
        if time is not None:
            self.scheduled_time = time
        if day is not None:
            self.schedule_day = day

        if self.is_running:
            self.start_scheduler()

        logger.info(f"Schedule config updated: frequency={self.schedule_frequency}, time={self.scheduled_time}, day={self.schedule_day}")

    def update_search_keywords(self, keywords):
        """更新搜索关键词"""
        self.search_keywords = keywords if isinstance(keywords, list) else [keywords] if keywords else []
        logger.info(f"Search keywords updated: {self.search_keywords}")

    def get_schedule_time(self):
        """获取当前调度时间"""
        return self.scheduled_time

    def get_schedule_config(self):
        """获取当前调度配置"""
        return {
            "frequency": self.schedule_frequency,
            "time": self.scheduled_time,
            "day": self.schedule_day,
            "search_keywords": self.search_keywords
        }

    def get_next_run_time(self):
        """获取下次运行时间"""
        jobs = schedule.get_jobs()
        if jobs:
            return jobs[0].next_run
        return None


# 全局调度器实例
scheduler = TagCloudScheduler()


def start_tag_cloud_scheduler():
    """启动标签云调度器（在应用启动时调用）"""
    import threading

    def run_scheduler():
        scheduler.start_scheduler()

    # 在单独线程中运行调度器
    scheduler_thread = threading.Thread(target=run_scheduler, daemon=True)
    scheduler_thread.start()
    logger.info("Tag cloud scheduler thread started")


def stop_tag_cloud_scheduler():
    """停止标签云调度器（在应用关闭时调用）"""
    scheduler.stop_scheduler()


def update_schedule_time(new_time):
    """更新调度时间"""
    scheduler.update_schedule_time(new_time)


def update_schedule_config(frequency=None, time=None, day=None):
    """更新调度配置"""
    scheduler.update_schedule_config(frequency, time, day)


def update_search_keywords(keywords):
    """更新搜索关键词"""
    scheduler.update_search_keywords(keywords)


def get_schedule_time():
    """获取当前调度时间"""
    return scheduler.get_schedule_time()


def get_schedule_config():
    """获取当前调度配置"""
    return scheduler.get_schedule_config()


def get_next_run_time():
    """获取下次运行时间"""
    return scheduler.get_next_run_time()


# 手动触发任务（用于测试）
async def trigger_manual_fetch():
    """手动触发标签获取"""
    logger.info("Manual tag fetch triggered")
    await scheduler.daily_fetch_task()

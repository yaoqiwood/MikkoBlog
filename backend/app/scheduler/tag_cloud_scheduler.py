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
        self.prompt_template = None  # 提示词模板

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

        # 持久化调度配置到数据库
        self._save_schedule_config_to_db()

        logger.info(f"Schedule time updated to: {new_time}")

    def update_schedule_config(self, frequency=None, time=None, day=None):
        """更新调度配置并持久化到数据库"""
        if self.is_running:
            # 如果调度器正在运行，需要重启
            self.stop_scheduler()

        if frequency is not None:
            self.schedule_frequency = frequency
        if time is not None:
            self.scheduled_time = time
        if day is not None:
            self.schedule_day = day

        # 持久化调度配置到数据库
        self._save_schedule_config_to_db()

        if self.is_running:
            self.start_scheduler()

        logger.info(f"Schedule config updated: frequency={self.schedule_frequency}, time={self.scheduled_time}, day={self.schedule_day}")

    def _save_schedule_config_to_db(self):
        """将调度配置保存到数据库"""
        try:
            from app.db.session import get_session
            from app.models.system_setting import SystemSetting
            from sqlmodel import select
            from datetime import datetime

            session = next(get_session())
            try:
                # 保存调度频率
                self._save_setting(session, "schedule_frequency", self.schedule_frequency)

                # 保存调度时间
                self._save_setting(session, "schedule_time", self.scheduled_time)

                # 保存调度日期
                self._save_setting(session, "schedule_day", self.schedule_day)

                # 计算并保存下次运行时间
                next_run_time = self._calculate_next_run_time()
                if next_run_time:
                    self._save_setting(session, "next_run_time", next_run_time.isoformat())

                session.commit()
                logger.info("调度配置已保存到数据库")
            finally:
                session.close()
        except Exception as e:
            logger.error(f"保存调度配置到数据库失败: {e}")

    def _save_setting(self, session, key_name, value):
        """保存单个设置到数据库"""
        from app.models.system_setting import SystemSetting
        from sqlmodel import select

        statement = select(SystemSetting).where(
            SystemSetting.category == "schedule",
            SystemSetting.key_name == key_name
        )
        setting = session.exec(statement).first()

        if setting:
            setting.key_value = str(value)
            setting.updated_at = datetime.utcnow()
        else:
            setting = SystemSetting(
                category="schedule",
                key_name=key_name,
                key_value=str(value),
                description=f"调度配置 - {key_name}"
            )
        session.add(setting)

    def _calculate_next_run_time(self):
        """计算下次运行时间"""
        try:
            from datetime import datetime, timedelta
            import schedule

            now = datetime.now()

            if self.schedule_frequency == "hourly":
                # 每小时运行
                next_run = now.replace(minute=0, second=0, microsecond=0) + timedelta(hours=1)
            elif self.schedule_frequency == "daily":
                # 每天在指定时间运行
                hour, minute = map(int, self.scheduled_time.split(':'))
                next_run = now.replace(hour=hour, minute=minute, second=0, microsecond=0)
                if next_run <= now:
                    next_run += timedelta(days=1)
            elif self.schedule_frequency == "weekly":
                # 每周在指定日期和时间运行
                day_map = {
                    "monday": 0, "tuesday": 1, "wednesday": 2, "thursday": 3,
                    "friday": 4, "saturday": 5, "sunday": 6
                }
                target_day = day_map.get(self.schedule_day.lower(), 0)
                hour, minute = map(int, self.scheduled_time.split(':'))

                # 计算下一个目标日期
                days_ahead = target_day - now.weekday()
                if days_ahead <= 0:  # 如果今天已经过了目标日期
                    days_ahead += 7

                next_run = now.replace(hour=hour, minute=minute, second=0, microsecond=0) + timedelta(days=days_ahead)
            else:
                return None

            return next_run
        except Exception as e:
            logger.error(f"计算下次运行时间失败: {e}")
            return None

    def update_search_keywords(self, keywords, prompt_template=None):
        """更新搜索关键词和提示词模板"""
        self.search_keywords = keywords if isinstance(keywords, list) else [keywords] if keywords else []
        self.prompt_template = prompt_template
        logger.info(f"Search keywords updated: {self.search_keywords}, prompt_template: {self.prompt_template}")

    def get_schedule_time(self):
        """获取当前调度时间"""
        return self.scheduled_time

    def get_schedule_config(self):
        """获取当前调度配置"""
        # 从数据库加载调度配置
        self._load_schedule_config_from_db()

        return {
            "frequency": self.schedule_frequency,
            "time": self.scheduled_time,
            "day": self.schedule_day,
            "search_keywords": self.search_keywords,
            "prompt_template": self.prompt_template
        }

    def _load_schedule_config_from_db(self):
        """从数据库加载调度配置"""
        try:
            from app.db.session import get_session
            from app.models.system_setting import SystemSetting
            from sqlmodel import select

            session = next(get_session())
            try:
                # 加载调度频率
                frequency_setting = session.exec(
                    select(SystemSetting).where(
                        SystemSetting.category == "schedule",
                        SystemSetting.key_name == "schedule_frequency"
                    )
                ).first()
                if frequency_setting and frequency_setting.key_value:
                    self.schedule_frequency = frequency_setting.key_value

                # 加载调度时间
                time_setting = session.exec(
                    select(SystemSetting).where(
                        SystemSetting.category == "schedule",
                        SystemSetting.key_name == "schedule_time"
                    )
                ).first()
                if time_setting and time_setting.key_value:
                    self.scheduled_time = time_setting.key_value

                # 加载调度日期
                day_setting = session.exec(
                    select(SystemSetting).where(
                        SystemSetting.category == "schedule",
                        SystemSetting.key_name == "schedule_day"
                    )
                ).first()
                if day_setting and day_setting.key_value:
                    self.schedule_day = day_setting.key_value

                logger.info(f"从数据库加载调度配置: frequency={self.schedule_frequency}, time={self.scheduled_time}, day={self.schedule_day}")
            finally:
                session.close()
        except Exception as e:
            logger.error(f"从数据库加载调度配置失败: {e}")

    def get_next_run_time(self):
        """获取下次运行时间"""
        # 首先尝试从数据库获取
        try:
            from app.db.session import get_session
            from app.models.system_setting import SystemSetting
            from sqlmodel import select
            from datetime import datetime

            session = next(get_session())
            try:
                next_run_setting = session.exec(
                    select(SystemSetting).where(
                        SystemSetting.category == "schedule",
                        SystemSetting.key_name == "next_run_time"
                    )
                ).first()

                if next_run_setting and next_run_setting.key_value:
                    try:
                        next_run_time = datetime.fromisoformat(next_run_setting.key_value)
                        # 检查时间是否已过期，如果过期则重新计算
                        if next_run_time > datetime.now():
                            return next_run_time
                        else:
                            # 时间已过期，重新计算并保存
                            new_next_run = self._calculate_next_run_time()
                            if new_next_run:
                                self._save_setting(session, "next_run_time", new_next_run.isoformat())
                                session.commit()
                            return new_next_run
                    except ValueError:
                        logger.warning("下次运行时间格式错误，重新计算")
            finally:
                session.close()
        except Exception as e:
            logger.error(f"从数据库获取下次运行时间失败: {e}")

        # 如果数据库中没有或获取失败，则从schedule库获取
        jobs = schedule.get_jobs()
        if jobs:
            return jobs[0].next_run

        # 如果schedule库中也没有，则计算下次运行时间
        return self._calculate_next_run_time()


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


def update_search_keywords(keywords, prompt_template=None):
    """更新搜索关键词和提示词模板"""
    scheduler.update_search_keywords(keywords, prompt_template)


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

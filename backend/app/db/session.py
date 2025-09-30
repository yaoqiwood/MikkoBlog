import logging
from typing import Generator

from sqlmodel import Session, SQLModel, create_engine

from app.core.config import settings

# 配置SQL日志
logging.basicConfig(level=logging.INFO)
sql_logger = logging.getLogger('sqlalchemy.engine')
sql_logger.setLevel(logging.INFO)

engine = create_engine(
    settings.database_url,
    echo=True,  # 启用SQL语句日志
    pool_pre_ping=True
)


def initialize_database() -> None:
    SQLModel.metadata.create_all(engine)


def get_db() -> Generator[Session, None, None]:
    with Session(engine) as session:
        yield session

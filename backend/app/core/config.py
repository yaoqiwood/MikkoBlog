import os
from typing import List

import yaml


class Settings:
    def __init__(self) -> None:
        root_dir = os.path.abspath(
            os.path.join(os.path.dirname(__file__), "..", "..")
        )
        default_config_path = os.path.join(root_dir, "config", "config.yaml")
        config_path = os.environ.get("MIKKO_CONFIG", default_config_path)

        if not os.path.isabs(config_path):
            config_path = os.path.abspath(os.path.join(root_dir, config_path))

        with open(config_path, "r", encoding="utf-8") as f:
            raw = yaml.safe_load(f) or {}

        server_cfg = raw.get("server", {})
        db_cfg = raw.get("database", {})
        cors_cfg = raw.get("cors", {})
        jwt_cfg = raw.get("jwt", {})
        admin_cfg = raw.get("admin", {})
        image_cfg = raw.get("image_search", {})

        self.environment: str = server_cfg.get("environment", "development")
        self.port: int = int(server_cfg.get("port", 8000))

        # 优先使用环境变量，然后使用配置文件
        if os.environ.get("DB_HOST"):
            # 从环境变量构建数据库URL
            db_host = os.environ.get("DB_HOST", "localhost")
            db_port = os.environ.get("DB_PORT", "3306")
            db_name = os.environ.get("DB_NAME", "mikkoBlog")
            db_user = os.environ.get("DB_USER", "mikko")
            db_password = os.environ.get("DB_PASSWORD", "mikko_pass")
            self.database_url = f"mysql+pymysql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
        else:
            self.database_url: str = db_cfg.get(
                "url",
                "sqlite:///./dev.db",
            )

        self.cors_allow_origins: List[str] = cors_cfg.get(
            "allow_origins", ["*"]
        )

        self.jwt_secret: str = os.environ.get(
            "JWT_SECRET", jwt_cfg.get("secret", "change_me")
        )
        self.jwt_algorithm: str = jwt_cfg.get("algorithm", "HS256")
        self.jwt_expires_minutes: int = int(
            jwt_cfg.get("expires_minutes", 60 * 24)
        )

        self.default_admin_email: str = admin_cfg.get(
            "email", "admin@example.com"
        )
        self.default_admin_password: str = admin_cfg.get(
            "password", "admin123"
        )

        # 图片搜索配置
        self.unsplash_access_key: str = image_cfg.get(
            "unsplash_access_key", "demo_key"
        )


settings = Settings()

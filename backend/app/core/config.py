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

        self.environment: str = server_cfg.get("environment", "development")
        self.port: int = int(server_cfg.get("port", 8000))

        self.database_url: str = db_cfg.get(
            "url",
            "sqlite:///./dev.db",
        )

        self.cors_allow_origins: List[str] = cors_cfg.get(
            "allow_origins", ["*"]
        )

        self.jwt_secret: str = os.environ.get(
            "MIKKO_JWT_SECRET", jwt_cfg.get("secret", "change_me")
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


settings = Settings()

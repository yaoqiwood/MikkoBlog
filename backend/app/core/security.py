from datetime import datetime, timedelta, timezone
from typing import Any, Optional

from jose import JWTError, jwt
from passlib.context import CryptContext


# 使用更现代的密码哈希方案，支持更长的密码
pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto",
    bcrypt__default_rounds=12,
    bcrypt__min_rounds=10,
    bcrypt__max_rounds=15
)


def hash_password(password: str) -> str:
    # 检查密码长度，如果超过72字节则使用SHA256预处理
    password_bytes = password.encode('utf-8')
    if len(password_bytes) > 72:
        import hashlib
        # 使用SHA256预处理长密码
        password_hash = hashlib.sha256(password_bytes).hexdigest()
        return pwd_context.hash(password_hash)
    else:
        # 短密码直接使用bcrypt
        return pwd_context.hash(password)


def verify_password(password: str, hashed_password: str) -> bool:
    # 检查密码长度，如果超过72字节则使用SHA256预处理
    password_bytes = password.encode('utf-8')
    if len(password_bytes) > 72:
        import hashlib
        # 使用SHA256预处理长密码
        password_hash = hashlib.sha256(password_bytes).hexdigest()
        return pwd_context.verify(password_hash, hashed_password)
    else:
        # 短密码直接使用bcrypt
        return pwd_context.verify(password, hashed_password)


def create_access_token(*, data: dict[str, Any], secret_key: str, algorithm: str, expires_minutes: int) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=expires_minutes)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, secret_key, algorithm=algorithm)
    return encoded_jwt


def decode_token(token: str, *, secret_key: str, algorithm: str) -> Optional[dict[str, Any]]:
    try:
        payload = jwt.decode(token, secret_key, algorithms=[algorithm])
        return payload
    except JWTError:
        return None

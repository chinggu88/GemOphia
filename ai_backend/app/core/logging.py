import logging
import os
import sys
from pythonjsonlogger import jsonlogger
import sentry_sdk
from sentry_sdk.integrations.logging import LoggingIntegration

def setup_logging():
    """
    로깅 설정:
    - JSON 포맷터 적용
    - Sentry 통합 (DSN이 있는 경우)
    """
    log_level = os.getenv("LOG_LEVEL", "INFO").upper()
    
    # 기본 로거 설정
    logger = logging.getLogger()
    logger.setLevel(log_level)
    
    # 기존 핸들러 제거
    for handler in logger.handlers:
        logger.removeHandler(handler)
        
    # 콘솔 핸들러 (JSON 포맷)
    console_handler = logging.StreamHandler(sys.stdout)
    formatter = jsonlogger.JsonFormatter(
        '%(asctime)s %(levelname)s %(name)s %(message)s',
        datefmt='%Y-%m-%dT%H:%M:%S%z'
    )
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    
    # Sentry 설정
    sentry_dsn = os.getenv("SENTRY_DSN")
    if sentry_dsn:
        sentry_logging = LoggingIntegration(
            level=logging.INFO,        # Capture info and above as breadcrumbs
            event_level=logging.ERROR  # Send errors as events
        )
        sentry_sdk.init(
            dsn=sentry_dsn,
            integrations=[sentry_logging],
            traces_sample_rate=1.0,
            environment=os.getenv("APP_ENV", "production")
        )
        logging.info("✅ Sentry integration enabled")
    else:
        logging.info("⚠️ Sentry DSN not found. Sentry disabled.")

    return logger

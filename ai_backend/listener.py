"""
Realtime Listener - 독립 실행 프로세스

이 스크립트는 Supabase Realtime을 구독하여 새로운 메시지를 감지하고
자동으로 AI 분석 파이프라인을 실행합니다.

실행 방법:
    python listener.py

중지 방법:
    Ctrl+C
"""
import asyncio
import logging
import signal
import sys
import time
from datetime import datetime

from app.services.realtime_listener import get_listener
from app.schedulers.daily_analysis import scheduler, daily_conversation_analysis
from app.core.logging import setup_logging

# 로깅 설정 초기화
logger = setup_logging()


# 우아한 종료를 위한 플래그
shutdown_event = asyncio.Event()


def signal_handler(sig, frame):
    """
    Ctrl+C 시그널 핸들러
    """
    logger.info("\n\n🛑 Shutdown signal received (Ctrl+C)")
    shutdown_event.set()


async def main():
    """
    메인 함수 - Realtime Listener 시작 및 유지
    """
    logger.info("=" * 80)
    logger.info("🚀 GemOphia Realtime Listener Starting...")
    logger.info("=" * 80)
    logger.info(f"Started at: {datetime.now().isoformat()}")
    logger.info("Press Ctrl+C to stop")
    logger.info("=" * 80)

    # Realtime Listener 시작
    try:
        # 스케줄러 시작
        scheduler.start()
        logger.info("⏰ Scheduler started")
        
        listener = get_listener()
        listener.start()

        logger.info("\n✅ Realtime Listener is now running!")
        logger.info("   Listening for new messages in 'messages' table...")
        logger.info("   Logs are saved to: listener.log\n")

        # 계속 실행 (종료 시그널 받을 때까지)
        while not shutdown_event.is_set():
            await asyncio.sleep(1)

    except KeyboardInterrupt:
        logger.info("\n\n🛑 Keyboard interrupt received")
    except Exception as e:
        logger.error(f"\n\n❌ Fatal error: {e}", exc_info=True)
    finally:
        # 정리 작업
        logger.info("\n🧹 Cleaning up...")
        try:
            listener = get_listener()
            listener.stop()
            logger.info("✅ Realtime Listener stopped successfully")
        except Exception as e:
            logger.error(f"Error during cleanup: {e}")

        logger.info("=" * 80)
        logger.info(f"Stopped at: {datetime.now().isoformat()}")
        logger.info("👋 Goodbye!")
        logger.info("=" * 80)


if __name__ == "__main__":
    # 시그널 핸들러 등록 (Ctrl+C)
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    # 이벤트 루프 실행
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass  # 이미 signal_handler에서 처리됨

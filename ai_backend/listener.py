"""
Realtime File Upload Listener

파일 업로드를 실시간으로 감지하고 자동으로 전처리 파이프라인을 실행합니다.

실행 방법:
    python listener.py

중지 방법:
    Ctrl+C
"""
import signal
import sys
import time
from app.services.realtime_listener import get_file_listener
from app.core.logging import setup_logging

# 로깅 설정
setup_logging()

# Global listener instance for signal handler
_listener = None


def signal_handler(sig, frame):
    """Graceful shutdown on Ctrl+C"""
    print("\n🛑 Shutting down listener...")
    if _listener:
        _listener.stop()
    sys.exit(0)


def main():
    """메인 실행 함수"""
    global _listener

    print("=" * 80)
    print("🎧 GemOphia AI Backend - Realtime File Upload Listener")
    print("=" * 80)
    print()
    print("📋 파이프라인:")
    print("   1. ai_conversation_files INSERT 감지")
    print("   2. Supabase Storage에서 파일 다운로드")
    print("   3. 적절한 Processor로 전처리")
    print("   4. ai_preprocessed_data에 결과 저장")
    print()
    print("=" * 80)
    print()

    # SIGINT 핸들러 등록 (Ctrl+C)
    signal.signal(signal.SIGINT, signal_handler)

    # 리스너 시작
    _listener = get_file_listener()
    _listener.start()

    print("💡 리스너가 백그라운드에서 실행 중입니다...")
    print("   파일 업로드를 기다리는 중... (Ctrl+C로 종료)\n")

    # 무한 루프로 메인 스레드 유지
    # Supabase Realtime 구독은 백그라운드 스레드에서 돌아가므로
    # 메인 스레드를 살려둬야 합니다
    try:
        while True:
            time.sleep(1)  # CPU 부하 방지
    except KeyboardInterrupt:
        print("\n🛑 Shutting down listener...")
        _listener.stop()
        sys.exit(0)


if __name__ == "__main__":
    main()

"""
Supabase Realtime Listener

파일이 업로드되면 (ai_conversation_files INSERT) 자동으로 전처리 파이프라인을 실행합니다.

파이프라인:
1. ai_conversation_files INSERT 감지
2. Supabase Storage에서 파일 다운로드
3. 적절한 Processor로 전처리
4. ai_preprocessed_data에 결과 저장
"""
import asyncio
from typing import Dict, Any
import logging

from ..core.supabase import get_supabase_client
from .file_service import get_file_service

logger = logging.getLogger(__name__)


class RealtimeFileListener:
    """
    Supabase Realtime을 사용해서 ai_conversation_files 테이블을 구독하고
    새 파일이 업로드되면 자동으로 전처리를 실행합니다.
    """

    def __init__(self):
        self.supabase = get_supabase_client()
        self.file_service = get_file_service()
        logger.info("✅ RealtimeFileListener initialized")
        self.channel = None

    async def handle_new_file(self, payload: Dict[str, Any]):
        """
        새 파일이 INSERT되면 호출되는 콜백 함수

        Args:
            payload: Supabase Realtime 이벤트 페이로드
                {
                    'type': 'INSERT',
                    'record': {
                        'id': 'uuid',
                        'couple_id': 'uuid',
                        'user_id': 'uuid',
                        'file_name': 'kakao_chat.txt',
                        'file_url': 'https://...',
                        'file_type': 'text/plain',
                        'status': 'pending',
                        'created_at': '2025-01-16T...'
                    },
                    'old_record': None
                }
        """
        try:
            # 1. 이벤트 타입 확인
            event_type = payload.get('type')
            file_record = payload.get('record', {})

            if event_type != 'INSERT':
                logger.info(f"Skipping non-INSERT event: {event_type}")
                return

            # 2. 파일 정보 추출
            file_id = file_record.get('id')
            file_name = file_record.get('file_name')
            couple_id = file_record.get('couple_id')
            user_id = file_record.get('user_id')

            if not file_id:
                logger.warning(f"Invalid file payload (missing id): {payload}")
                return

            logger.info(
                f"🔔 New file uploaded!\n"
                f"   File ID: {file_id[:8]}...\n"
                f"   File Name: {file_name}\n"
                f"   Couple: {couple_id[:8] if couple_id else 'unknown'}...\n"
                f"   User: {user_id[:8] if user_id else 'unknown'}..."
            )

            # 3. 파일 전처리 파이프라인 실행
            logger.info(f"🚀 Starting file preprocessing pipeline for {file_id[:8]}...")

            result = await self.file_service.process_file_from_storage(file_id)

            logger.info(
                f"✅ File preprocessing completed!\n"
                f"   File ID: {file_id[:8]}...\n"
                f"   File Type: {result.file_type}\n"
                f"   Total Messages: {result.total_messages}\n"
                f"   Participants: {result.participants}\n"
                f"   Success: {result.success}"
            )

            # TODO Phase 2: 전처리 완료 후 AI 분석 파이프라인 자동 실행
            # - 감정 분석 (emotion analysis)
            # - NER 추출 (날짜, 장소, 활동)
            # - 키워드 추출
            # - 대화 요약
            # - LSM, Turn-taking 분석

        except Exception as e:
            logger.error(
                f"❌ Error handling new file:\n"
                f"   File ID: {file_record.get('id', 'unknown')}\n"
                f"   Error: {e}",
                exc_info=True
            )

    def start(self):
        """
        Realtime 구독 시작

        ai_conversation_files 테이블의 INSERT 이벤트를 구독합니다.
        """
        try:
            logger.info("🚀 Starting Supabase Realtime listener...")

            # Realtime 채널 생성
            self.channel = self.supabase.channel('file-upload-listener')

            # ai_conversation_files 테이블의 INSERT 이벤트 구독
            self.channel.on_postgres_changes(
                event='INSERT',                  # INSERT 이벤트만 감지
                schema='public',                 # public 스키마
                table='ai_conversation_files',   # ai_conversation_files 테이블
                callback=lambda payload: asyncio.create_task(
                    self.handle_new_file(payload)
                )
            ).subscribe()

            logger.info(
                "✅ Realtime listener started successfully!\n"
                "   Listening for new files in 'ai_conversation_files' table...\n"
                "   Press Ctrl+C to stop."
            )

        except Exception as e:
            logger.error(f"❌ Failed to start Realtime listener: {e}", exc_info=True)
            raise

    def stop(self):
        """
        Realtime 구독 중지
        """
        if self.channel:
            try:
                self.supabase.remove_channel(self.channel)
                logger.info("🛑 Realtime listener stopped")
            except Exception as e:
                logger.error(f"Error stopping listener: {e}")


# 싱글톤 인스턴스
_listener_instance = None


def get_file_listener() -> RealtimeFileListener:
    """Realtime 파일 리스너 싱글톤 인스턴스 반환"""
    global _listener_instance
    if _listener_instance is None:
        _listener_instance = RealtimeFileListener()
    return _listener_instance

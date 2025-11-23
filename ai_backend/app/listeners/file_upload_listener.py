"""
File Upload Realtime Listener

ai_conversation_files 테이블의 INSERT 이벤트를 구독하여
새로운 파일이 업로드되면 자동으로 전처리를 시작합니다.
"""
import asyncio
import logging
import threading
from typing import Dict, Any, Optional
from concurrent.futures import ThreadPoolExecutor

from ..core.supabase import get_async_supabase_client
from ..services.file_service import get_file_service
from supabase import AsyncClient

logger = logging.getLogger(__name__)


class FileUploadListener:
    """
    파일 업로드 Realtime Listener

    ai_conversation_files 테이블의 INSERT 이벤트 감지
    """

    def __init__(self):
        self.supabase: Optional[AsyncClient] = None
        self.file_service = get_file_service()
        self.channel = None
        self.executor = ThreadPoolExecutor(max_workers=4, thread_name_prefix="file-processor")
        self._initialized = False

    async def start(self):
        """Realtime 구독 시작 (비동기)"""
        try:
            logger.info("🎧 Starting File Upload Listener...")

            # Async Supabase 클라이언트 초기화
            if not self._initialized:
                self.supabase = await get_async_supabase_client()
                self._initialized = True

            # Realtime 채널 생성
            self.channel = self.supabase.channel('ai_conversation_files_changes')

            # INSERT 이벤트 구독
            await self.channel.on_postgres_changes(
                'INSERT',  # event
                schema='public',
                table='ai_conversation_files',
                callback=self._handle_new_file
            ).subscribe()  # await 추가!

            logger.info("✅ File Upload Listener started successfully")
            logger.info("   Listening for new files in ai_conversation_files table...")

        except Exception as e:
            logger.error(f"❌ Failed to start File Upload Listener: {e}", exc_info=True)
            raise

    def _handle_new_file(self, payload: Dict[str, Any]):
        """
        새 파일 INSERT 이벤트 핸들러

        Args:
            payload: Realtime 이벤트 페이로드
        """
        try:
            # 새로 추가된 레코드 (payload.data.record 구조)
            data = payload.get('data', {})
            new_record = data.get('record', {})
            file_id = new_record.get('id')
            file_name = new_record.get('original_file_name') or new_record.get('file_name')

            logger.info(f"📥 New file detected: {file_name} (ID: {file_id})")

            # 비동기 전처리 작업을 별도 스레드에서 실행
            self.executor.submit(self._run_async_processing, file_id, file_name)

        except Exception as e:
            logger.error(f"❌ Error handling new file event: {e}", exc_info=True)

    def _run_async_processing(self, file_id: str, file_name: str):
        """
        비동기 처리를 위한 동기 래퍼

        ThreadPoolExecutor에서 실행되며 새로운 이벤트 루프를 생성합니다.
        """
        try:
            # 새 이벤트 루프 생성
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            try:
                loop.run_until_complete(self._process_file_async(file_id, file_name))
            finally:
                loop.close()
        except Exception as e:
            logger.error(f"❌ Error in async processing wrapper: {e}", exc_info=True)

    async def _process_file_async(self, file_id: str, file_name: str):
        """
        비동기 파일 전처리

        Args:
            file_id: 파일 ID
            file_name: 파일 이름
        """
        try:
            logger.info(f"🚀 Starting async file processing: {file_name}")

            # FileService를 통해 전처리 실행
            result = await self.file_service.process_file_from_storage(file_id)

            if result.success:
                logger.info(f"✅ File processed successfully: {file_name}")
                logger.info(f"   Total messages: {result.total_messages}")
                logger.info(f"   Participants: {result.participants}")
            else:
                logger.warning(f"⚠️ File processing completed with errors: {file_name}")
                logger.warning(f"   Error: {result.error_message}")

        except Exception as e:
            logger.error(f"❌ Async file processing failed: {e}", exc_info=True)

    def stop(self):
        """Realtime 구독 중지"""
        try:
            if self.channel:
                self.supabase.remove_channel(self.channel)
                logger.info("🛑 File Upload Listener stopped")

            # Executor 종료
            self.executor.shutdown(wait=True, cancel_futures=False)
            logger.info("🛑 File processing executor stopped")
        except Exception as e:
            logger.error(f"Error stopping listener: {e}")


# 싱글톤 인스턴스
_listener_instance = None


def get_file_upload_listener() -> FileUploadListener:
    """File Upload Listener 싱글톤 인스턴스 반환"""
    global _listener_instance
    if _listener_instance is None:
        _listener_instance = FileUploadListener()
    return _listener_instance

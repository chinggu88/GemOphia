"""
File Service

Supabase Storage에서 파일을 가져와 전처리하는 메인 서비스
"""
import os
import tempfile
import httpx
from typing import Optional
from datetime import datetime
import logging

from ..core.supabase import get_supabase_client
from .file_processors.processor_factory import FileProcessorFactory
from .file_processors.base_processor import ProcessedFile

logger = logging.getLogger(__name__)


def sanitize_text(text: Optional[str]) -> Optional[str]:
    """
    PostgreSQL TEXT 타입에 저장할 수 없는 문자 제거

    Args:
        text: 원본 텍스트

    Returns:
        정제된 텍스트
    """
    if not text:
        return text

    # NULL 바이트 제거 (PostgreSQL TEXT 타입은 \u0000을 지원하지 않음)
    text = text.replace('\u0000', '')

    # 기타 제어 문자 제거 (선택적)
    # text = ''.join(char for char in text if char.isprintable() or char in '\n\r\t')

    return text


class FileService:
    """
    파일 처리 서비스

    1. ai_conversation_files 테이블에서 파일 정보 조회
    2. Supabase Storage에서 파일 다운로드
    3. 적절한 프로세서로 전처리
    4. ai_preprocessed_data 테이블에 결과 저장
    """

    def __init__(self):
        self.supabase = get_supabase_client()

    async def process_file_from_storage(
        self,
        file_id: str
    ) -> ProcessedFile:
        """
        Supabase Storage에서 파일을 가져와 처리

        Args:
            file_id: ai_conversation_files 테이블의 레코드 ID

        Returns:
            ProcessedFile: 처리 결과
        """
        try:
            logger.info(f"🔄 Processing file from storage: {file_id}")

            # 1. ai_conversation_files 테이블에서 메타데이터 조회
            file_record = self.supabase.table('ai_conversation_files') \
                .select('*') \
                .eq('id', file_id) \
                .single() \
                .execute()

            if not file_record.data:
                raise ValueError(f"File record not found: {file_id}")

            file_data = file_record.data
            file_url = file_data['file_url']
            file_name = file_data.get('original_file_name') or file_data['file_name']
            couple_id = file_data.get('couple_id')
            user_id = file_data.get('user_id')

            logger.info(f"   File: {file_name}")
            logger.info(f"   URL: {file_url}")

            # 2. status를 'processing'으로 업데이트
            self.supabase.table('ai_conversation_files') \
                .update({'status': 'processing'}) \
                .eq('id', file_id) \
                .execute()

            # 3. 파일 다운로드 (file_url에서 직접)
            local_path = await self._download_from_url(file_url, file_name)

            # 4. 적절한 프로세서로 처리
            processor = FileProcessorFactory.get_processor(file_name)

            if not processor:
                raise ValueError(
                    f"No processor found for file: {file_name}. "
                    f"Supported extensions: {FileProcessorFactory.get_supported_extensions()}"
                )

            result = await processor.process(local_path)

            # 5. 처리 결과를 ai_preprocessed_data 테이블에 저장
            await self._save_to_preprocessed_data(
                file_id=file_id,
                couple_id=couple_id,
                user_id=user_id,
                result=result
            )

            # 6. ai_conversation_files status를 'completed'로 업데이트
            self.supabase.table('ai_conversation_files') \
                .update({'status': 'completed'}) \
                .eq('id', file_id) \
                .execute()

            # 7. 임시 파일 삭제
            if os.path.exists(local_path):
                os.remove(local_path)
                logger.debug(f"🗑️ Deleted temp file: {local_path}")

            logger.info(f"✅ File processing completed: {file_id}")
            return result

        except Exception as e:
            logger.error(f"❌ File processing failed: {e}", exc_info=True)

            # 실패 상태로 업데이트
            try:
                self.supabase.table('ai_conversation_files') \
                    .update({'status': 'failed'}) \
                    .eq('id', file_id) \
                    .execute()
            except:
                pass

            raise

    async def _download_from_url(
        self,
        file_url: str,
        file_name: str
    ) -> str:
        """
        URL에서 파일 다운로드

        Args:
            file_url: 파일 URL (Supabase Storage public URL)
            file_name: 파일 이름

        Returns:
            str: 로컬 임시 파일 경로
        """
        try:
            logger.info(f"⬇️ Downloading from URL: {file_url[:50]}...")

            # HTTP GET으로 파일 다운로드
            async with httpx.AsyncClient(timeout=60.0) as client:
                response = await client.get(file_url)
                response.raise_for_status()

            # 임시 파일로 저장
            temp_dir = tempfile.mkdtemp()
            local_path = os.path.join(temp_dir, file_name)

            with open(local_path, 'wb') as f:
                f.write(response.content)

            logger.info(f"✅ Downloaded to: {local_path}")
            return local_path

        except Exception as e:
            logger.error(f"Download failed: {e}")
            raise

    async def _save_to_preprocessed_data(
        self,
        file_id: str,
        couple_id: Optional[str],
        user_id: Optional[str],
        result: ProcessedFile
    ):
        """
        처리 결과를 ai_preprocessed_data 테이블에 저장

        Args:
            file_id: 파일 ID
            couple_id: 커플 ID
            user_id: 사용자 ID
            result: 처리 결과
        """
        try:
            # 대화 데이터를 JSONB 형식으로 변환 (텍스트 정제)
            parsed_conversations = []
            if result.conversations:
                for msg in result.conversations:
                    parsed_conversations.append({
                        'timestamp': msg.timestamp.isoformat() if msg.timestamp else None,
                        'sender': sanitize_text(msg.sender),
                        'message': sanitize_text(msg.message),
                        'metadata': msg.metadata
                    })

            # ai_preprocessed_data에 INSERT
            # NOTE: user_id는 profiles 테이블에 레코드가 있어야 함
            # 테스트용으로 일단 None 설정 (실제 앱 사용 시 자동 생성됨)
            preprocessed_data = {
                'file_id': file_id,
                'couple_id': couple_id,
                'user_id': None,  # profiles에 레코드 없으면 FK 에러 발생하므로 None
                'processing_status': 'completed' if result.success else 'failed',
                'extracted_text': sanitize_text(result.raw_text),
                'parsed_conversations': parsed_conversations,
                'total_messages': result.total_messages,
                'participants': result.participants,
                'date_range': {
                    'start': result.date_range['start'].isoformat() if result.date_range and result.date_range.get('start') else None,
                    'end': result.date_range['end'].isoformat() if result.date_range and result.date_range.get('end') else None,
                } if result.date_range else None,
                'file_type': result.file_type,
                'error_message': result.error_message if not result.success else None,
                'warnings': result.warnings,
                'processed_at': datetime.now().isoformat()
            }

            insert_result = self.supabase.table('ai_preprocessed_data') \
                .insert(preprocessed_data) \
                .execute()

            logger.info(f"💾 Saved preprocessing result to ai_preprocessed_data")

            if insert_result.data:
                preprocessed_id = insert_result.data[0]['id']
                logger.info(f"   Preprocessed data ID: {preprocessed_id}")

        except Exception as e:
            logger.error(f"Failed to save preprocessing result: {e}")
            raise


# 싱글톤 인스턴스
_file_service_instance = None


def get_file_service() -> FileService:
    """File Service 싱글톤 인스턴스 반환"""
    global _file_service_instance
    if _file_service_instance is None:
        _file_service_instance = FileService()
    return _file_service_instance

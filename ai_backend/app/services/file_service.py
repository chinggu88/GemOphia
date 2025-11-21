"""
File Service

Supabase Storage에서 파일을 가져와 전처리하는 메인 서비스
"""
import os
import tempfile
from typing import Optional
from datetime import datetime
import logging

from ..core.supabase import get_supabase_client
from .file_processors.processor_factory import FileProcessorFactory
from .file_processors.base_processor import ProcessedFile

logger = logging.getLogger(__name__)


class FileService:
    """
    파일 처리 서비스

    1. Supabase Storage에서 파일 다운로드
    2. 적절한 프로세서로 전처리
    3. 결과를 ai_conversation_files 테이블에 저장
    """

    def __init__(self):
        self.supabase = get_supabase_client()

    async def process_file_from_storage(
        self,
        file_id: str,
        bucket_name: str = 'conversation-files'
    ) -> ProcessedFile:
        """
        Supabase Storage에서 파일을 가져와 처리

        Args:
            file_id: ai_conversation_files 테이블의 레코드 ID
            bucket_name: Supabase Storage 버킷 이름

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
            storage_path = file_data['storage_path']
            file_name = file_data['file_name']
            couple_id = file_data['couple_id']

            logger.info(f"   File: {file_name}")
            logger.info(f"   Storage path: {storage_path}")

            # 2. processing 상태로 업데이트
            self.supabase.table('ai_conversation_files') \
                .update({'processing_status': 'processing'}) \
                .eq('id', file_id) \
                .execute()

            # 3. Supabase Storage에서 파일 다운로드
            local_path = await self._download_from_storage(
                bucket_name,
                storage_path,
                file_name
            )

            # 4. 적절한 프로세서로 처리
            processor = FileProcessorFactory.get_processor(file_name)

            if not processor:
                raise ValueError(
                    f"No processor found for file: {file_name}. "
                    f"Supported extensions: {FileProcessorFactory.get_supported_extensions()}"
                )

            result = await processor.process(local_path)

            # 5. 처리 결과를 DB에 저장
            await self._save_processing_result(file_id, couple_id, result)

            # 6. 임시 파일 삭제
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
                    .update({
                        'processing_status': 'failed',
                        'processed_at': datetime.now().isoformat()
                    }) \
                    .eq('id', file_id) \
                    .execute()
            except:
                pass

            raise

    async def _download_from_storage(
        self,
        bucket_name: str,
        storage_path: str,
        file_name: str
    ) -> str:
        """
        Supabase Storage에서 파일 다운로드

        Args:
            bucket_name: 버킷 이름
            storage_path: Storage 경로
            file_name: 파일 이름

        Returns:
            str: 로컬 임시 파일 경로
        """
        try:
            logger.info(f"⬇️ Downloading from Supabase Storage...")

            # 파일 다운로드
            response = self.supabase.storage.from_(bucket_name).download(storage_path)

            # 임시 파일로 저장
            temp_dir = tempfile.mkdtemp()
            local_path = os.path.join(temp_dir, file_name)

            with open(local_path, 'wb') as f:
                f.write(response)

            logger.info(f"✅ Downloaded to: {local_path}")
            return local_path

        except Exception as e:
            logger.error(f"Download failed: {e}")
            raise

    async def _save_processing_result(
        self,
        file_id: str,
        couple_id: str,
        result: ProcessedFile
    ):
        """
        처리 결과를 DB에 저장

        Args:
            file_id: 파일 ID
            couple_id: 커플 ID
            result: 처리 결과
        """
        try:
            # 1. ai_conversation_files 테이블 업데이트
            update_data = {
                'processing_status': 'completed' if result.success else 'failed',
                'processed_at': datetime.now().isoformat(),
                'extracted_text': result.raw_text[:10000] if result.raw_text else None,  # 텍스트 일부만 저장
                'extracted_conversations': [
                    {
                        'timestamp': msg.timestamp.isoformat() if msg.timestamp else None,
                        'sender': msg.sender,
                        'message': msg.message,
                        'metadata': msg.metadata
                    }
                    for msg in (result.conversations or [])
                ],
                'analysis_summary': {
                    'total_messages': result.total_messages,
                    'participants': result.participants,
                    'date_range': {
                        'start': result.date_range['start'].isoformat() if result.date_range else None,
                        'end': result.date_range['end'].isoformat() if result.date_range else None,
                    } if result.date_range else None,
                    'warnings': result.warnings
                }
            }

            self.supabase.table('ai_conversation_files') \
                .update(update_data) \
                .eq('id', file_id) \
                .execute()

            logger.info(f"💾 Saved processing result to ai_conversation_files")

            # 2. conversations 테이블에 대화 INSERT
            if result.success and result.conversations:
                await self._insert_conversations_to_db(couple_id, result.conversations)

        except Exception as e:
            logger.error(f"Failed to save processing result: {e}")
            raise

    async def _insert_conversations_to_db(self, couple_id: str, conversations):
        """
        파싱된 대화를 conversations 테이블에 INSERT

        Args:
            couple_id: 커플 ID
            conversations: 대화 메시지 리스트
        """
        try:
            logger.info(f"💾 Inserting {len(conversations)} conversations to DB...")

            # TODO: user_id 매핑 필요 (발신자 이름 → user_id)
            # 지금은 임시로 couple_id만 사용

            for msg in conversations:
                conversation_data = {
                    'couple_id': couple_id,
                    'user_id': None,  # TODO: 발신자 이름으로 user_id 찾기
                    'content': msg.message,
                    'conversation_type': 'ai_imported',  # 파일에서 가져온 대화 표시
                    'created_at': msg.timestamp.isoformat() if msg.timestamp else datetime.now().isoformat()
                }

                self.supabase.table('conversations').insert(conversation_data).execute()

            logger.info(f"✅ Inserted {len(conversations)} conversations")

        except Exception as e:
            logger.error(f"Failed to insert conversations: {e}")
            # 여기서는 에러를 raise하지 않고 warning만 로깅
            # (파일 처리는 성공했지만 DB INSERT만 실패한 경우)
            logger.warning("⚠️ Conversations were not saved to DB, but file processing succeeded")


# 싱글톤 인스턴스
_file_service_instance = None


def get_file_service() -> FileService:
    """File Service 싱글톤 인스턴스 반환"""
    global _file_service_instance
    if _file_service_instance is None:
        _file_service_instance = FileService()
    return _file_service_instance

"""
카카오톡 CSV Processor

카카오톡 대화 내보내기 CSV 파일 처리 (PC 버전)
형식: Date,User,Message
"""
import csv
from datetime import datetime
from typing import List
import logging

from .base_processor import BaseFileProcessor, ProcessedFile, ConversationMessage

logger = logging.getLogger(__name__)


class KakaoCsvProcessor(BaseFileProcessor):
    """카카오톡 CSV 파일 프로세서"""

    processor_name = "KakaoCsvProcessor"
    supported_extensions = ['.csv']

    async def process(self, file_path: str, **kwargs) -> ProcessedFile:
        """
        CSV 파일 처리

        Args:
            file_path: CSV 파일 경로

        Returns:
            ProcessedFile: 처리 결과
        """
        try:
            logger.info(f"Processing CSV file: {file_path}")

            # CSV 파일 읽기
            conversations = []
            participants = set()

            # utf-8-sig: BOM(Byte Order Mark) 자동 제거
            with open(file_path, 'r', encoding='utf-8-sig') as f:
                reader = csv.DictReader(f)

                for row in reader:
                    try:
                        # Date, User, Message 컬럼 읽기
                        date_str = row.get('Date', '').strip()
                        user = row.get('User', '').strip()
                        message = row.get('Message', '').strip()

                        if not date_str or not user or not message:
                            logger.warning(f"Skipping row with missing fields: {row}")
                            continue

                        # 날짜 파싱 (YYYY-MM-DD HH:MM:SS)
                        timestamp = datetime.strptime(date_str, '%Y-%m-%d %H:%M:%S')

                        # 대화 메시지 생성
                        conv_msg = ConversationMessage(
                            timestamp=timestamp,
                            sender=user,
                            message=message
                        )
                        conversations.append(conv_msg)

                        # 참여자 추가
                        participants.add(user)

                    except Exception as e:
                        logger.warning(f"Failed to parse row: {row}, error: {e}")
                        continue

            # 날짜 범위 계산
            date_range = None
            if conversations:
                timestamps = [msg.timestamp for msg in conversations if msg.timestamp]
                if timestamps:
                    date_range = {
                        'start': min(timestamps),
                        'end': max(timestamps)
                    }

            # 전체 텍스트 (대화 내용 연결)
            raw_text = '\n'.join([
                f"[{msg.timestamp}] {msg.sender}: {msg.message}"
                for msg in conversations
            ])

            logger.info(f"✅ CSV parsing completed: {len(conversations)} messages, {len(participants)} participants")

            return ProcessedFile(
                success=True,
                file_type='csv',
                raw_text=raw_text,
                conversations=conversations,
                total_messages=len(conversations),
                participants=list(participants),
                date_range=date_range,
                warnings=[]
            )

        except Exception as e:
            logger.error(f"CSV processing failed: {e}", exc_info=True)
            return ProcessedFile(
                success=False,
                file_type='csv',
                error_message=str(e)
            )

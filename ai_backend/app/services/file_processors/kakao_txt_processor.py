"""
카카오톡 텍스트 파일 프로세서

카카오톡 대화 내보내기로 생성된 txt 파일 파싱
"""
import re
from typing import List
from datetime import datetime
import logging

from .base_processor import BaseFileProcessor, ProcessedFile, ConversationMessage

logger = logging.getLogger(__name__)


class KakaoTxtProcessor(BaseFileProcessor):
    """
    카카오톡 txt 파일 프로세서

    예상 포맷:
    ------------------- 2024년 1월 15일 월요일 -------------------
    [철수] [오후 2:30] 오늘 저녁 뭐 먹을까?
    [영희] [오후 2:32] 파스타 어때?
    [철수] [오후 2:35] 좋아!
    """

    @property
    def supported_extensions(self) -> List[str]:
        return ['.txt']

    @property
    def processor_name(self) -> str:
        return 'KakaoTxtProcessor'

    async def process(self, file_path: str, **kwargs) -> ProcessedFile:
        """
        카카오톡 txt 파일 처리

        Args:
            file_path: 파일 경로
            **kwargs:
                - encoding: 파일 인코딩 (기본값: 'utf-8')

        Returns:
            ProcessedFile: 처리 결과
        """
        encoding = kwargs.get('encoding', 'utf-8')

        try:
            logger.info(f"📄 Processing Kakao txt file: {file_path}")

            # 파일 읽기
            with open(file_path, 'r', encoding=encoding) as f:
                raw_text = f.read()

            # 대화 파싱
            conversations = self._parse_conversations(raw_text)

            if not conversations:
                logger.warning("No conversations found in file")
                return ProcessedFile(
                    success=False,
                    file_type='kakao_txt',
                    raw_text=raw_text,
                    error_message="대화 메시지를 찾을 수 없습니다"
                )

            # 메타데이터 추출
            participants = self.extract_participants(conversations)
            date_range = self.extract_date_range(conversations)

            logger.info(
                f"✅ Parsed {len(conversations)} messages from {len(participants)} participants"
            )

            return ProcessedFile(
                success=True,
                file_type='kakao_txt',
                raw_text=raw_text,
                conversations=conversations,
                total_messages=len(conversations),
                participants=participants,
                date_range=date_range
            )

        except Exception as e:
            logger.error(f"❌ Error processing Kakao txt file: {e}", exc_info=True)
            return ProcessedFile(
                success=False,
                file_type='kakao_txt',
                error_message=str(e)
            )

    def _parse_conversations(self, text: str) -> List[ConversationMessage]:
        """
        텍스트에서 대화 메시지 추출

        Args:
            text: 원본 텍스트

        Returns:
            List[ConversationMessage]: 파싱된 메시지 리스트
        """
        conversations = []
        lines = text.split('\n')

        current_date = None  # 현재 날짜 컨텍스트

        for line in lines:
            line = line.strip()
            if not line:
                continue

            # 날짜 구분선 파싱
            # 예: "------------------- 2024년 1월 15일 월요일 -------------------"
            date_match = re.match(r'-+\s*(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일', line)
            if date_match:
                year, month, day = date_match.groups()
                current_date = datetime(int(year), int(month), int(day))
                continue

            # 메시지 파싱
            # 패턴 1: [발신자] [시간] 메시지
            # 예: "[철수] [오후 2:30] 오늘 저녁 뭐 먹을까?"
            msg_match = re.match(r'\[(.+?)\]\s*\[(.+?)\]\s*(.+)', line)

            if msg_match:
                sender = msg_match.group(1).strip()
                time_str = msg_match.group(2).strip()
                message = msg_match.group(3).strip()

                # 시간 파싱
                timestamp = self._parse_time(current_date, time_str)

                if timestamp:
                    conversations.append(ConversationMessage(
                        timestamp=timestamp,
                        sender=sender,
                        message=message
                    ))
                else:
                    logger.warning(f"Failed to parse timestamp: {time_str}")

        return conversations

    def _parse_time(self, base_date: datetime, time_str: str) -> datetime:
        """
        시간 문자열을 datetime으로 변환

        Args:
            base_date: 기준 날짜
            time_str: 시간 문자열 (예: "오후 2:30", "오전 11:15")

        Returns:
            datetime: 파싱된 시간
        """
        if not base_date:
            return None

        try:
            # "오후 2:30" 형식 파싱
            match = re.match(r'(오전|오후)\s*(\d{1,2}):(\d{2})', time_str)
            if not match:
                return None

            period, hour, minute = match.groups()
            hour = int(hour)
            minute = int(minute)

            # 오후 변환 (12시간제 → 24시간제)
            if period == '오후' and hour != 12:
                hour += 12
            elif period == '오전' and hour == 12:
                hour = 0

            return base_date.replace(hour=hour, minute=minute, second=0, microsecond=0)

        except Exception as e:
            logger.warning(f"Time parsing error for '{time_str}': {e}")
            return None

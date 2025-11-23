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

            # 형식 감지 (한글 vs 영문)
            is_english = self._detect_format(raw_text)
            format_type = "English" if is_english else "Korean"
            logger.info(f"   Detected format: {format_type}")

            # 대화 파싱
            conversations = self._parse_conversations(raw_text, is_english)

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

    def _detect_format(self, text: str) -> bool:
        """
        텍스트 파일 형식 감지 (한글 vs 영문)

        Args:
            text: 원본 텍스트

        Returns:
            bool: True if English format, False if Korean format
        """
        # 영문 형식 패턴 체크
        # "KakaoTalk Chats with" 또는 "January 1, 2022 at" 같은 패턴
        english_patterns = [
            r'KakaoTalk Chats with',
            r'Date Saved\s*:',
            r'[A-Z][a-z]+\s+\d{1,2},\s+\d{4}\s+at\s+\d{1,2}:\d{2}\s+[AP]M'
        ]

        for pattern in english_patterns:
            if re.search(pattern, text[:1000]):  # 첫 1000자만 확인
                return True

        # 한글 형식 패턴 체크
        korean_patterns = [
            r'\d{4}년\s*\d{1,2}월\s*\d{1,2}일',
            r'\[.+?\]\s*\[오전|오후\s+\d{1,2}:\d{2}\]'
        ]

        for pattern in korean_patterns:
            if re.search(pattern, text[:1000]):
                return False

        # 기본값: 한글
        return False

    def _parse_conversations(self, text: str, is_english: bool = False) -> List[ConversationMessage]:
        """
        텍스트에서 대화 메시지 추출

        Args:
            text: 원본 텍스트
            is_english: True if English format, False if Korean format

        Returns:
            List[ConversationMessage]: 파싱된 메시지 리스트
        """
        if is_english:
            return self._parse_english_format(text)
        else:
            return self._parse_korean_format(text)

    def _parse_english_format(self, text: str) -> List[ConversationMessage]:
        """
        영문 형식 카카오톡 파일 파싱

        예시:
        January 3, 2022 at 5:59 PM, ♥그만개겨김송♥ : 헤이헤이헤이헤이헤이
        """
        conversations = []
        lines = text.split('\n')

        for line in lines:
            line = line.strip()
            if not line:
                continue

            # 영문 형식 메시지 파싱
            # 패턴: "January 3, 2022 at 5:59 PM, sender : message"
            msg_match = re.match(
                r'([A-Z][a-z]+\s+\d{1,2},\s+\d{4})\s+at\s+(\d{1,2}:\d{2}\s+[AP]M),\s*(.+?)\s*:\s*(.+)',
                line
            )

            if msg_match:
                date_str = msg_match.group(1)  # "January 3, 2022"
                time_str = msg_match.group(2)  # "5:59 PM"
                sender = msg_match.group(3).strip()
                message = msg_match.group(4).strip()

                try:
                    # 날짜/시간 파싱
                    datetime_str = f"{date_str} {time_str}"
                    timestamp = datetime.strptime(datetime_str, "%B %d, %Y %I:%M %p")

                    conversations.append(ConversationMessage(
                        timestamp=timestamp,
                        sender=sender,
                        message=message
                    ))
                except Exception as e:
                    logger.warning(f"Failed to parse English format line: {line[:100]}, error: {e}")

        return conversations

    def _parse_korean_format(self, text: str) -> List[ConversationMessage]:
        """
        한글 형식 카카오톡 파일 파싱

        예시:
        2025년 2월 14일 오후 2:07, 딱복 🍑 : 소영님 몸은 괜찮으신가여..
        """
        conversations = []
        lines = text.split('\n')

        for line in lines:
            line = line.strip()
            if not line:
                continue

            # 한글 형식 메시지 파싱
            # 패턴: "2025년 2월 14일 오후 2:07, 딱복 🍑 : 소영님 몸은 괜찮으신가여.."
            msg_match = re.match(
                r'(\d{4})년\s+(\d{1,2})월\s+(\d{1,2})일\s+(오전|오후)\s+(\d{1,2}):(\d{2}),\s*(.+?)\s*:\s*(.+)',
                line
            )

            if msg_match:
                year = int(msg_match.group(1))
                month = int(msg_match.group(2))
                day = int(msg_match.group(3))
                period = msg_match.group(4)  # 오전/오후
                hour = int(msg_match.group(5))
                minute = int(msg_match.group(6))
                sender = msg_match.group(7).strip()
                message = msg_match.group(8).strip()

                try:
                    # 오후 변환 (12시간제 → 24시간제)
                    if period == '오후' and hour != 12:
                        hour += 12
                    elif period == '오전' and hour == 12:
                        hour = 0

                    timestamp = datetime(year, month, day, hour, minute, 0)

                    conversations.append(ConversationMessage(
                        timestamp=timestamp,
                        sender=sender,
                        message=message
                    ))
                except Exception as e:
                    logger.warning(f"Failed to parse Korean format line: {line[:100]}, error: {e}")

        return conversations

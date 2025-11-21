"""
Base File Processor

모든 파일 프로세서의 추상 클래스
"""
from abc import ABC, abstractmethod
from typing import List, Dict, Any, Optional
from dataclasses import dataclass
from datetime import datetime


@dataclass
class ConversationMessage:
    """파싱된 대화 메시지"""
    timestamp: datetime
    sender: str  # 발신자 이름 or ID
    message: str  # 메시지 내용
    metadata: Optional[Dict[str, Any]] = None  # 추가 메타데이터 (이모티콘, 사진 등)


@dataclass
class ProcessedFile:
    """파일 처리 결과"""
    success: bool
    file_type: str  # 'kakao_txt', 'pdf', 'audio', etc.

    # 추출된 데이터
    raw_text: Optional[str] = None  # 원본 텍스트
    conversations: Optional[List[ConversationMessage]] = None  # 파싱된 대화

    # 메타데이터
    total_messages: int = 0
    participants: List[str] = None  # 참여자 목록
    date_range: Optional[Dict[str, datetime]] = None  # {'start': ..., 'end': ...}

    # 에러 정보
    error_message: Optional[str] = None
    warnings: List[str] = None

    def __post_init__(self):
        if self.participants is None:
            self.participants = []
        if self.warnings is None:
            self.warnings = []
        if self.conversations:
            self.total_messages = len(self.conversations)


class BaseFileProcessor(ABC):
    """
    파일 프로세서 추상 클래스

    모든 파일 타입별 프로세서는 이 클래스를 상속받아 구현합니다.
    """

    @property
    @abstractmethod
    def supported_extensions(self) -> List[str]:
        """이 프로세서가 지원하는 파일 확장자 목록"""
        pass

    @property
    @abstractmethod
    def processor_name(self) -> str:
        """프로세서 이름 (로깅용)"""
        pass

    @abstractmethod
    async def process(self, file_path: str, **kwargs) -> ProcessedFile:
        """
        파일을 처리하여 대화 데이터 추출

        Args:
            file_path: 파일 경로 (로컬 또는 Supabase Storage URL)
            **kwargs: 프로세서별 추가 옵션

        Returns:
            ProcessedFile: 처리 결과
        """
        pass

    def validate_file(self, file_path: str) -> bool:
        """
        파일 유효성 검사

        Args:
            file_path: 파일 경로

        Returns:
            bool: 유효 여부
        """
        # 확장자 체크
        extension = file_path.split('.')[-1].lower()
        return f".{extension}" in self.supported_extensions

    def extract_participants(self, conversations: List[ConversationMessage]) -> List[str]:
        """
        대화에서 참여자 목록 추출

        Args:
            conversations: 대화 메시지 리스트

        Returns:
            List[str]: 중복 제거된 참여자 목록
        """
        if not conversations:
            return []

        participants = set()
        for msg in conversations:
            if msg.sender:
                participants.add(msg.sender)

        return sorted(list(participants))

    def extract_date_range(self, conversations: List[ConversationMessage]) -> Optional[Dict[str, datetime]]:
        """
        대화의 날짜 범위 추출

        Args:
            conversations: 대화 메시지 리스트

        Returns:
            Dict[str, datetime]: {'start': ..., 'end': ...}
        """
        if not conversations:
            return None

        timestamps = [msg.timestamp for msg in conversations if msg.timestamp]

        if not timestamps:
            return None

        return {
            'start': min(timestamps),
            'end': max(timestamps)
        }

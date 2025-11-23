"""
File Processor Factory

파일 확장자에 따라 적절한 프로세서를 선택하는 팩토리
"""
from typing import Optional
import logging

from .base_processor import BaseFileProcessor
from .kakao_txt_processor import KakaoTxtProcessor
from .kakao_csv_processor import KakaoCsvProcessor
from .pdf_processor import PdfProcessor
from .audio_processor import AudioProcessor

logger = logging.getLogger(__name__)


class FileProcessorFactory:
    """
    파일 프로세서 팩토리

    파일 확장자 또는 MIME 타입에 따라 적절한 프로세서를 반환합니다.
    """

    # 등록된 프로세서 목록
    _processors = [
        KakaoTxtProcessor(),
        KakaoCsvProcessor(),
        PdfProcessor(),
        AudioProcessor(),
    ]

    @classmethod
    def get_processor(cls, file_path: str) -> Optional[BaseFileProcessor]:
        """
        파일 경로에 적합한 프로세서 반환

        Args:
            file_path: 파일 경로 (확장자로 판단)

        Returns:
            BaseFileProcessor: 적합한 프로세서 또는 None
        """
        # 확장자 추출
        extension = f".{file_path.split('.')[-1].lower()}"

        logger.debug(f"Finding processor for extension: {extension}")

        # 지원하는 프로세서 찾기
        for processor in cls._processors:
            if extension in processor.supported_extensions:
                logger.info(f"✅ Selected processor: {processor.processor_name}")
                return processor

        logger.warning(f"⚠️ No processor found for extension: {extension}")
        return None

    @classmethod
    def get_supported_extensions(cls) -> list[str]:
        """
        지원하는 모든 파일 확장자 목록 반환

        Returns:
            list[str]: 확장자 목록
        """
        extensions = set()
        for processor in cls._processors:
            extensions.update(processor.supported_extensions)

        return sorted(list(extensions))

    @classmethod
    def register_processor(cls, processor: BaseFileProcessor):
        """
        새 프로세서 등록

        Args:
            processor: 등록할 프로세서 인스턴스
        """
        if processor not in cls._processors:
            cls._processors.append(processor)
            logger.info(f"✅ Registered processor: {processor.processor_name}")

    @classmethod
    def list_processors(cls) -> dict:
        """
        등록된 모든 프로세서 정보 반환

        Returns:
            dict: {프로세서명: 지원 확장자} 매핑
        """
        return {
            processor.processor_name: processor.supported_extensions
            for processor in cls._processors
        }

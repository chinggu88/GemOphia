"""
PDF 파일 프로세서

PDF에서 텍스트 추출 후 대화 형식 파싱
"""
from typing import List
import logging

from .base_processor import BaseFileProcessor, ProcessedFile, ConversationMessage
from .kakao_txt_processor import KakaoTxtProcessor

logger = logging.getLogger(__name__)


class PdfProcessor(BaseFileProcessor):
    """
    PDF 파일 프로세서

    PDF에서 텍스트를 추출한 후, 카카오톡 형식으로 파싱 시도
    """

    def __init__(self):
        self.kakao_parser = KakaoTxtProcessor()

    @property
    def supported_extensions(self) -> List[str]:
        return ['.pdf']

    @property
    def processor_name(self) -> str:
        return 'PdfProcessor'

    async def process(self, file_path: str, **kwargs) -> ProcessedFile:
        """
        PDF 파일 처리

        Args:
            file_path: 파일 경로
            **kwargs:
                - extract_images: 이미지도 추출할지 여부 (기본값: False)

        Returns:
            ProcessedFile: 처리 결과
        """
        try:
            logger.info(f"📄 Processing PDF file: {file_path}")

            # PDF에서 텍스트 추출
            raw_text = await self._extract_text_from_pdf(file_path)

            if not raw_text:
                logger.warning("No text found in PDF")
                return ProcessedFile(
                    success=False,
                    file_type='pdf',
                    error_message="PDF에서 텍스트를 추출할 수 없습니다"
                )

            # 카카오톡 형식으로 파싱 시도
            conversations = self.kakao_parser._parse_conversations(raw_text)

            if not conversations:
                # 파싱 실패 시 raw_text만 반환
                logger.warning("Could not parse conversations from PDF text")
                return ProcessedFile(
                    success=True,
                    file_type='pdf',
                    raw_text=raw_text,
                    conversations=[],
                    warnings=["PDF 텍스트를 대화 형식으로 파싱할 수 없습니다"]
                )

            # 성공
            participants = self.extract_participants(conversations)
            date_range = self.extract_date_range(conversations)

            logger.info(
                f"✅ Extracted {len(conversations)} messages from PDF"
            )

            return ProcessedFile(
                success=True,
                file_type='pdf',
                raw_text=raw_text,
                conversations=conversations,
                total_messages=len(conversations),
                participants=participants,
                date_range=date_range
            )

        except Exception as e:
            logger.error(f"❌ Error processing PDF file: {e}", exc_info=True)
            return ProcessedFile(
                success=False,
                file_type='pdf',
                error_message=str(e)
            )

    async def _extract_text_from_pdf(self, file_path: str) -> str:
        """
        PDF에서 텍스트 추출

        Args:
            file_path: PDF 파일 경로

        Returns:
            str: 추출된 텍스트
        """
        try:
            # pdfplumber 사용 (설치 필요: pip install pdfplumber)
            import pdfplumber

            text_parts = []

            with pdfplumber.open(file_path) as pdf:
                logger.info(f"📖 PDF has {len(pdf.pages)} pages")

                for page_num, page in enumerate(pdf.pages, 1):
                    page_text = page.extract_text()

                    if page_text:
                        text_parts.append(page_text)
                        logger.debug(f"   Page {page_num}: {len(page_text)} characters")

            full_text = '\n'.join(text_parts)
            logger.info(f"✅ Extracted {len(full_text)} characters from PDF")

            return full_text

        except ImportError:
            logger.error("pdfplumber not installed. Run: pip install pdfplumber")
            raise ImportError(
                "pdfplumber is required for PDF processing. "
                "Install it with: pip install pdfplumber"
            )
        except Exception as e:
            logger.error(f"PDF text extraction failed: {e}")
            raise

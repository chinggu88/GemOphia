"""
오디오 파일 프로세서

STT (Speech-to-Text)를 사용하여 음성을 텍스트로 변환
"""
from typing import List
from datetime import datetime
import logging

from .base_processor import BaseFileProcessor, ProcessedFile, ConversationMessage

logger = logging.getLogger(__name__)


class AudioProcessor(BaseFileProcessor):
    """
    오디오 파일 프로세서

    Whisper 또는 Google STT를 사용하여 음성 → 텍스트 변환
    """

    @property
    def supported_extensions(self) -> List[str]:
        return ['.mp3', '.wav', '.m4a', '.ogg', '.flac']

    @property
    def processor_name(self) -> str:
        return 'AudioProcessor'

    async def process(self, file_path: str, **kwargs) -> ProcessedFile:
        """
        오디오 파일 처리 (STT)

        Args:
            file_path: 파일 경로
            **kwargs:
                - stt_provider: 'whisper' (기본값) 또는 'google'
                - language: 언어 코드 (기본값: 'ko')
                - model_size: Whisper 모델 크기 (tiny, base, small, medium, large)

        Returns:
            ProcessedFile: 처리 결과
        """
        stt_provider = kwargs.get('stt_provider', 'whisper')
        language = kwargs.get('language', 'ko')

        try:
            logger.info(f"🎤 Processing audio file: {file_path}")
            logger.info(f"   STT Provider: {stt_provider}")

            # STT 실행
            if stt_provider == 'whisper':
                transcribed_text = await self._transcribe_with_whisper(
                    file_path,
                    language=language,
                    model_size=kwargs.get('model_size', 'base')
                )
            elif stt_provider == 'google':
                transcribed_text = await self._transcribe_with_google(
                    file_path,
                    language=language
                )
            else:
                raise ValueError(f"Unsupported STT provider: {stt_provider}")

            if not transcribed_text:
                logger.warning("No text transcribed from audio")
                return ProcessedFile(
                    success=False,
                    file_type='audio',
                    error_message="음성에서 텍스트를 추출할 수 없습니다"
                )

            logger.info(f"✅ Transcribed {len(transcribed_text)} characters")

            # 음성 파일은 단일 메시지로 처리 (화자 분리 없이)
            # TODO: 화자 분리 (Speaker Diarization) 추가 고려
            conversations = [ConversationMessage(
                timestamp=datetime.now(),  # TODO: 파일 생성 시간 사용
                sender="Unknown",  # TODO: 화자 분리 후 식별
                message=transcribed_text,
                metadata={
                    'stt_provider': stt_provider,
                    'language': language,
                    'original_file': file_path
                }
            )]

            return ProcessedFile(
                success=True,
                file_type='audio',
                raw_text=transcribed_text,
                conversations=conversations,
                total_messages=1,
                warnings=["화자 분리가 구현되지 않았습니다. 전체 내용이 단일 메시지로 처리됩니다."]
            )

        except Exception as e:
            logger.error(f"❌ Error processing audio file: {e}", exc_info=True)
            return ProcessedFile(
                success=False,
                file_type='audio',
                error_message=str(e)
            )

    async def _transcribe_with_whisper(
        self,
        file_path: str,
        language: str = 'ko',
        model_size: str = 'base'
    ) -> str:
        """
        Whisper를 사용한 STT

        Args:
            file_path: 오디오 파일 경로
            language: 언어 코드
            model_size: 모델 크기 (tiny, base, small, medium, large)

        Returns:
            str: 변환된 텍스트
        """
        try:
            import whisper

            logger.info(f"🤖 Loading Whisper model: {model_size}")
            model = whisper.load_model(model_size)

            logger.info(f"🎙️ Transcribing audio...")
            result = model.transcribe(
                file_path,
                language=language,
                verbose=False
            )

            return result['text']

        except ImportError:
            logger.error("Whisper not installed. Run: pip install openai-whisper")
            raise ImportError(
                "Whisper is required for audio processing. "
                "Install it with: pip install openai-whisper"
            )
        except Exception as e:
            logger.error(f"Whisper transcription failed: {e}")
            raise

    async def _transcribe_with_google(self, file_path: str, language: str = 'ko') -> str:
        """
        Google Speech-to-Text API 사용

        Args:
            file_path: 오디오 파일 경로
            language: 언어 코드 (ko-KR, en-US 등)

        Returns:
            str: 변환된 텍스트
        """
        # TODO: Google STT API 구현
        raise NotImplementedError("Google STT is not implemented yet")

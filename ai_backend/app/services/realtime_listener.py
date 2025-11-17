"""
Supabase Realtime Listener

새로운 메시지가 DB에 들어오면 자동으로 분석 파이프라인을 실행합니다.

Phase 1: 기본 리스너 + 간단한 감정 분석
Phase 2: STT, NER, Auto-Scheduler 추가 예정
"""
import asyncio
from typing import Dict, Any
import logging
from datetime import datetime

from ..core.supabase import get_supabase_client
from .emotion_analyzer import analyze_text_emotion

logger = logging.getLogger(__name__)


class RealtimeMessageListener:
    """
    Supabase Realtime을 사용해서 messages 테이블을 구독하고
    새 메시지가 들어오면 자동으로 분석합니다.
    """

    def __init__(self):
        self.supabase = get_supabase_client()
        self.channel = None

    async def handle_new_message(self, payload: Dict[str, Any]):
        """
        새 메시지가 INSERT되면 호출되는 콜백 함수

        Args:
            payload: Supabase Realtime 이벤트 페이로드
                {
                    'type': 'INSERT',
                    'record': {
                        'id': 'uuid',
                        'couple_id': 'uuid',
                        'sender_id': 'uuid',
                        'content': '메시지 내용',
                        'message_type': 'text',
                        'created_at': '2025-01-16T...'
                    },
                    'old_record': None
                }
        """
        try:
            # 1. 메시지 데이터 추출
            event_type = payload.get('type')
            message = payload.get('record', {})

            if event_type != 'INSERT':
                logger.info(f"Skipping non-INSERT event: {event_type}")
                return

            message_id = message.get('id')
            content = message.get('content')
            message_type = message.get('message_type', 'text')
            couple_id = message.get('couple_id')

            if not message_id or not content:
                logger.warning(f"Invalid message payload: {payload}")
                return

            logger.info(
                f"🔔 New message received!\n"
                f"   ID: {message_id[:8]}...\n"
                f"   Couple: {couple_id[:8] if couple_id else 'unknown'}...\n"
                f"   Type: {message_type}\n"
                f"   Content: {content[:50]}..."
            )

            # ============================================================
            # Phase 1: 간단한 감정 분석만 실행
            # ============================================================

            # TODO Phase 2: STT 처리 (message_type == 'voice'일 때)
            # if message_type == 'voice':
            #     content = await stt_service.transcribe(content)

            # TODO Phase 2: NER 처리 (날짜, 장소, 활동 추출)
            # ner_results = await ner_service.extract(content)

            # TODO Phase 2: 자동 일정 생성
            # if ner_results:
            #     await auto_scheduler.create_schedule(ner_results)

            # 2. 감정 분석 실행 (기존 코드 활용)
            logger.info(f"🤖 Analyzing emotion for message {message_id[:8]}...")
            emotion_result = await analyze_text_emotion(content)

            logger.info(
                f"✅ Analysis complete!\n"
                f"   Emotion: {emotion_result.emotion}\n"
                f"   Confidence: {emotion_result.confidence:.2f}\n"
                f"   Scores: {emotion_result.all_scores}"
            )

            # 3. 분석 결과를 DB에 저장
            analysis_data = {
                'message_id': message_id,
                'emotion': emotion_result.emotion,
                'confidence': float(emotion_result.confidence),
                'all_scores': emotion_result.all_scores,
                'topics': [],  # TODO Phase 2: 주제 추출 기능 추가
                'keywords': [],  # TODO Phase 2: 키워드 추출 기능 추가
                'processed_at': datetime.now().isoformat()
            }

            result = self.supabase.table('analysis_results').insert(analysis_data).execute()

            logger.info(
                f"💾 Analysis result saved to DB!\n"
                f"   Result ID: {result.data[0]['id'][:8]}..."
            )

            # TODO Phase 2: 추가 파이프라인
            # - conversation_summaries (일별 요약)
            # - topic_history 업데이트
            # - user_preferences 학습

        except Exception as e:
            logger.error(
                f"❌ Error handling new message:\n"
                f"   Message ID: {message.get('id', 'unknown')}\n"
                f"   Error: {e}",
                exc_info=True
            )

    def start(self):
        """
        Realtime 구독 시작

        messages 테이블의 INSERT 이벤트를 구독합니다.
        """
        try:
            logger.info("🚀 Starting Supabase Realtime listener...")

            # Realtime 채널 생성
            self.channel = self.supabase.channel('messages-listener')

            # messages 테이블의 INSERT 이벤트 구독
            self.channel.on_postgres_changes(
                event='INSERT',          # INSERT 이벤트만 감지
                schema='public',         # public 스키마
                table='messages',        # messages 테이블
                callback=lambda payload: asyncio.create_task(
                    self.handle_new_message(payload)
                )
            ).subscribe()

            logger.info(
                "✅ Realtime listener started successfully!\n"
                "   Listening for new messages in 'messages' table...\n"
                "   Press Ctrl+C to stop."
            )

        except Exception as e:
            logger.error(f"❌ Failed to start Realtime listener: {e}", exc_info=True)
            raise

    def stop(self):
        """
        Realtime 구독 중지
        """
        if self.channel:
            try:
                self.supabase.remove_channel(self.channel)
                logger.info("🛑 Realtime listener stopped")
            except Exception as e:
                logger.error(f"Error stopping listener: {e}")


# 싱글톤 인스턴스
_listener_instance = None


def get_listener() -> RealtimeMessageListener:
    """Realtime 리스너 싱글톤 인스턴스 반환"""
    global _listener_instance
    if _listener_instance is None:
        _listener_instance = RealtimeMessageListener()
    return _listener_instance

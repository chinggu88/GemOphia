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
from ..services.ner_service import NERService
from ..services.schedule_service import ScheduleService

logger = logging.getLogger(__name__)


class RealtimeMessageListener:
    """
    Supabase Realtime을 사용해서 messages 테이블을 구독하고
    새 메시지가 들어오면 자동으로 분석합니다.
    """

    def __init__(self):
        self.supabase = get_supabase_client()
        self.ner_service = NERService()
        self.schedule_service = ScheduleService()
        logger.info("✅ RealtimeMessageListener initialized")
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

            conversation_id = message.get('id')
            content = message.get('content')
            conversation_type = message.get('conversation_type', 'daily')
            couple_id = message.get('couple_id')
            user_id = message.get('user_id')

            if not conversation_id or not content:
                logger.warning(f"Invalid conversation payload: {payload}")
                return

            logger.info(
                f"🔔 New conversation received!\n"
                f"   ID: {conversation_id[:8]}...\n"
                f"   Couple: {couple_id[:8] if couple_id else 'unknown'}...\n"
                f"   User: {user_id[:8] if user_id else 'unknown'}...\n"
                f"   Type: {conversation_type}\n"
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
            logger.info(f"🤖 Analyzing emotion for conversation {conversation_id[:8]}...")
            emotion_result = await analyze_text_emotion(content)

            logger.info(
                f"✅ Analysis complete!\n"
                f"   Emotion: {emotion_result.emotion}\n"
                f"   Confidence: {emotion_result.confidence:.2f}\n"
                f"   Scores: {emotion_result.all_scores}"
            )

            # 3. 분석 결과를 conversations 테이블에 업데이트
            # sentiment와 emotion_score 컬럼 활용
            update_data = {
                'sentiment': emotion_result.emotion,  # positive/negative/neutral
                'emotion_score': int(emotion_result.confidence * 100)  # 0-100
            }

            self.supabase.table('conversations').update(update_data).eq('id', conversation_id).execute()

            logger.info(
                f"💾 Emotion analysis saved to conversations table!\n"
                f"   Conversation ID: {conversation_id[:8]}...\n"
                f"   Sentiment: {update_data['sentiment']}\n"
                f"   Score: {update_data['emotion_score']}"
            )

            # 4. analysis_results 테이블에 상세 분석 결과 저장
            analysis_data = {
                'conversation_id': conversation_id,
                'emotion': emotion_result.emotion,
                'confidence': float(emotion_result.confidence),
                'all_scores': emotion_result.all_scores,
                'voice_emotion': getattr(emotion_result, 'voice_emotion', None),
                'topics': [],  # TODO: Phase 3에서 주제 추출 기능 추가
                'keywords': [],  # TODO: Phase 1.5에서 키워드 추출 기능 추가
                'processed_at': datetime.now().isoformat()
            }
            
            try:
                self.supabase.table('analysis_results').insert(analysis_data).execute()
                logger.info(f"💾 Detailed analysis saved to analysis_results table for {conversation_id[:8]}")
            except Exception as db_error:
                logger.error(f"⚠️ Failed to save analysis_results: {db_error}")

            # 5. NER 및 일정 추출 (Phase 3)
            try:
                entities = await self.ner_service.extract_entities(content)
                if entities:
                    logger.info(f"🔍 Found {len(entities)} entities in message")
                    
                    # ner_extractions 저장
                    ner_data = [
                        {
                            'conversation_id': conversation_id,
                            'entity_type': e.type,
                            'entity_value': e.value,
                            'confidence': float(e.confidence),
                            'extracted_at': datetime.now().isoformat()
                        }
                        for e in entities
                    ]
                    self.supabase.table('ner_extractions').insert(ner_data).execute()
                    
                    # 일정 자동 생성 로직
                    # couple_id가 필요함. conversation_id로 couple_id를 조회해야 하지만, 
                    # 성능을 위해 메시지 페이로드나 캐시에서 가져오는 것이 좋음.
                    # 여기서는 일단 DB에서 조회한다고 가정 (또는 payload에 있다고 가정)
                    # payload에 couple_id가 없다면 conversation 조회 필요
                    
                    # 임시: conversation_id로 couple_id 조회
                    conv_res = self.supabase.table('conversations').select('couple_id').eq('id', conversation_id).single().execute()
                    if conv_res.data:
                        couple_id = conv_res.data['couple_id']
                        await self.schedule_service.create_pending_schedule(couple_id, entities, content)
                    
            except Exception as ner_error:
                logger.error(f"⚠️ NER extraction failed: {ner_error}")

            # TODO Phase 2: 추가 파이프라인
            # - conversation_summaries (일별 요약)
            # - topic_history 업데이트
            # - user_preferences 학습

        except Exception as e:
            logger.error(
                f"❌ Error handling new conversation:\n"
                f"   Conversation ID: {message.get('id', 'unknown')}\n"
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

            # conversations 테이블의 INSERT 이벤트 구독
            self.channel.on_postgres_changes(
                event='INSERT',          # INSERT 이벤트만 감지
                schema='public',         # public 스키마
                table='conversations',   # conversations 테이블 (실제 DB 테이블명)
                callback=lambda payload: asyncio.create_task(
                    self.handle_new_message(payload)
                )
            ).subscribe()

            logger.info(
                "✅ Realtime listener started successfully!\n"
                "   Listening for new messages in 'conversations' table...\n"
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

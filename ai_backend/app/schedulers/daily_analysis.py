import logging
from datetime import date, datetime
from collections import Counter
from apscheduler.schedulers.asyncio import AsyncIOScheduler

from ..core.supabase import get_supabase_client
from ..services.lsm_analyzer import LSMAnalyzer
from ..services.turn_taking_analyzer import TurnTakingAnalyzer
from ..services.emotion_analyzer import analyze_text_emotion

logger = logging.getLogger(__name__)

scheduler = AsyncIOScheduler()
lsm_analyzer = LSMAnalyzer()
turn_taking_analyzer = TurnTakingAnalyzer()

def calculate_emotion_summary(messages: list[dict]) -> dict:
    """
    메시지들의 감정 분포를 계산합니다.
    """
    if not messages:
        return {"긍정": 0, "중립": 0, "부정": 0}

    # 감정 카테고리 매핑
    POSITIVE = ["기쁨", "사랑"]
    NEGATIVE = ["슬픔", "화남", "불안", "피곤"]
    NEUTRAL = ["중립"]

    emotion_counts = Counter()
    total_messages = 0

    for msg in messages:
        # analysis_results 테이블에서 감정 정보를 가져왔다고 가정하거나
        # conversations 테이블의 sentiment 컬럼을 사용
        sentiment = msg.get('sentiment')
        if not sentiment:
            continue
        
        total_messages += 1
        if sentiment in POSITIVE:
            emotion_counts["긍정"] += 1
        elif sentiment in NEGATIVE:
            emotion_counts["부정"] += 1
        else:
            emotion_counts["중립"] += 1

    if total_messages == 0:
        return {"긍정": 0, "중립": 0, "부정": 0}

    return {
        "긍정": round(emotion_counts["긍정"] / total_messages, 2),
        "중립": round(emotion_counts["중립"] / total_messages, 2),
        "부정": round(emotion_counts["부정"] / total_messages, 2)
    }

def calculate_health_score(emotion_summary: dict, lsm_score: float, balance_score: float) -> float:
    """
    관계 건강도 계산
    공식: 감정(40%) + LSM(30%) + 균형(30%)
    """
    positive_ratio = emotion_summary.get('긍정', 0)
    emotion_score = positive_ratio * 100
    lsm_score_100 = lsm_score * 100
    
    health_score = (
        emotion_score * 0.4 +
        lsm_score_100 * 0.3 +
        balance_score * 0.3
    )
    return min(health_score, 100.0)

async def analyze_couple_day(couple_id: str, analysis_date: date):
    """특정 커플의 하루 대화 분석"""
    supabase = get_supabase_client()
    
    # 1. 오늘의 메시지 조회
    # UTC 기준으로 00:00 ~ 23:59 조회 (간소화를 위해 단순 날짜 비교 사용)
    # 실제 프로덕션에서는 타임존 고려 필요
    start_time = f"{analysis_date} 00:00:00"
    end_time = f"{analysis_date} 23:59:59"

    try:
        response = supabase.table('conversations')\
            .select('*')\
            .eq('couple_id', couple_id)\
            .gte('created_at', start_time)\
            .lte('created_at', end_time)\
            .execute()
        
        messages = response.data
        
        if len(messages) < 2:
            logger.info(f"Couple {couple_id}: Not enough messages ({len(messages)})")
            return

        # 2. 감정 요약
        emotion_summary = calculate_emotion_summary(messages)
        
        # 지배적인 감정 찾기 (단순화: 가장 높은 비율)
        dominant_emotion = max(emotion_summary.items(), key=lambda x: x[1])[0]

        # 3. LSM 분석
        lsm_result = lsm_analyzer.analyze_conversation(messages)

        # 4. 턴테이킹 분석
        turn_taking_result = turn_taking_analyzer.analyze_conversation(messages)

        # 5. 관계 건강도 계산
        relationship_health = calculate_health_score(
            emotion_summary=emotion_summary,
            lsm_score=lsm_result.lsm_score,
            balance_score=turn_taking_result.balance_score
        )

        # 6. 갈등 감지
        conflict_detected = emotion_summary.get('부정', 0) > 0.3
        conflict_intensity = emotion_summary.get('부정', 0) if conflict_detected else 0.0

        # 7. 키워드 추출 (TODO: TextRank 구현 필요, 현재는 빈 리스트)
        keywords = []

        # 8. conversation_analysis 저장
        analysis_data = {
            'couple_id': couple_id,
            'analysis_date': str(analysis_date),
            'emotion_summary': emotion_summary,
            'dominant_emotion': dominant_emotion,
            'lsm_score': float(lsm_result.lsm_score),
            'lsm_details': lsm_result.category_breakdown,
            'turn_taking': {
                'balance_score': turn_taking_result.balance_score,
                'turn_ratio': turn_taking_result.turn_ratio,
                'avg_response_time': turn_taking_result.avg_response_time,
                'interruption_rate': turn_taking_result.interruption_rate
            },
            'relationship_health': float(relationship_health),
            'conflict_detected': conflict_detected,
            'conflict_intensity': float(conflict_intensity),
            'keywords': keywords
        }

        supabase.table('conversation_analysis')\
            .upsert(analysis_data, on_conflict='couple_id,analysis_date')\
            .execute()

        logger.info(
            f"✅ Daily analysis complete for couple {couple_id}: "
            f"Health={relationship_health:.1f}, Conflict={conflict_detected}"
        )

    except Exception as e:
        logger.error(f"Error analyzing couple {couple_id}: {e}", exc_info=True)

@scheduler.scheduled_job('cron', hour=23, minute=59)
async def daily_conversation_analysis():
    """일별 대화 분석 배치"""
    supabase = get_supabase_client()
    today = date.today()
    
    logger.info(f"Starting daily analysis for {today}")

    try:
        # 모든 커플 조회
        response = supabase.table('couples').select('id').execute()
        couples = response.data

        for couple in couples:
            await analyze_couple_day(couple['id'], today)
            
    except Exception as e:
        logger.error(f"Error in daily analysis job: {e}", exc_info=True)

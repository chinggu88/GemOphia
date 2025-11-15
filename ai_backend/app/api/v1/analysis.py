"""
Analysis API Endpoints
"""
from fastapi import APIRouter, HTTPException, Depends
from ...models.schemas import (
    MessageAnalysisRequest,
    MessageAnalysisResponse,
    ConversationAnalysisRequest,
    ConversationAnalysisResponse,
    EmotionScore,
)
from ...services.emotion_analyzer import analyze_text_emotion
from ...services.lsm_analyzer import LSMAnalyzer
from ...services.turn_taking_analyzer import TurnTakingAnalyzer
from datetime import datetime

router = APIRouter(prefix="/analysis", tags=["analysis"])


@router.post("/message", response_model=MessageAnalysisResponse)
async def analyze_message(request: MessageAnalysisRequest):
    """
    단일 메시지 분석

    - 감정 분석
    - 주제 추출 (TODO)
    """
    try:
        # 감정 분석
        emotion = await analyze_text_emotion(request.content)

        # TODO: 주제 분석 추가
        topics = []

        return MessageAnalysisResponse(
            message_id=None,
            emotion=emotion,
            topics=topics,
            processed_at=datetime.now()
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")


@router.post("/conversation", response_model=ConversationAnalysisResponse)
async def analyze_conversation(request: ConversationAnalysisRequest):
    """
    전체 대화 분석

    - 감정 요약
    - LSM 점수
    - 턴테이킹 분석
    - 관계 건강도 계산
    """
    try:
        # 1. 감정 분석 (모든 메시지)
        emotions = []
        for msg in request.messages:
            emotion = await analyze_text_emotion(msg['content'])
            emotions.append(emotion)

        # 감정 요약 계산
        emotion_summary = _calculate_emotion_summary(emotions)

        # 2. LSM 분석
        lsm_analyzer = LSMAnalyzer()
        lsm_score = lsm_analyzer.analyze_conversation(request.messages)

        # 3. 턴테이킹 분석
        turn_analyzer = TurnTakingAnalyzer()
        turn_taking = turn_analyzer.analyze_conversation(request.messages)

        # 4. 관계 건강도 계산
        relationship_health = _calculate_relationship_health(
            emotion_summary,
            lsm_score.lsm_score,
            turn_taking.balance_score
        )

        # 5. 갈등 감지 (간단한 규칙 기반)
        conflict_detected = emotion_summary.get('부정', 0) > 0.3
        conflict_intensity = emotion_summary.get('부정', 0) if conflict_detected else None

        # 6. 키워드 추출 (TODO: 개선 필요)
        keywords = _extract_keywords(request.messages)

        return ConversationAnalysisResponse(
            couple_id=request.couple_id,
            emotion_summary=emotion_summary,
            lsm_score=lsm_score,
            turn_taking=turn_taking,
            keywords=keywords,
            relationship_health=relationship_health,
            conflict_detected=conflict_detected,
            conflict_intensity=conflict_intensity,
            processed_at=datetime.now()
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Conversation analysis failed: {str(e)}")


# ===== Helper Functions =====

def _calculate_emotion_summary(emotions: list[EmotionScore]) -> dict[str, float]:
    """
    감정 분석 결과를 요약 (긍정/중립/부정)

    Args:
        emotions: 감정 분석 결과 리스트

    Returns:
        dict: {긍정: 0.65, 중립: 0.25, 부정: 0.10}
    """
    positive_emotions = ['기쁨', '사랑']
    neutral_emotions = ['중립', '피곤']
    negative_emotions = ['슬픔', '화남', '불안']

    total_positive = 0
    total_neutral = 0
    total_negative = 0

    for emotion in emotions:
        scores = emotion.all_scores

        for emo_name, score in scores.items():
            if emo_name in positive_emotions:
                total_positive += score
            elif emo_name in neutral_emotions:
                total_neutral += score
            elif emo_name in negative_emotions:
                total_negative += score

    total = total_positive + total_neutral + total_negative
    if total == 0:
        return {'긍정': 0.5, '중립': 0.5, '부정': 0.0}

    return {
        '긍정': round(total_positive / total, 3),
        '중립': round(total_neutral / total, 3),
        '부정': round(total_negative / total, 3),
    }


def _calculate_relationship_health(
    emotion_summary: dict[str, float],
    lsm_score: float,
    balance_score: float
) -> float:
    """
    관계 건강도 계산 (0-100)

    가중치:
    - 감정 (긍정): 40%
    - LSM 점수: 30%
    - 턴테이킹 균형: 30%
    """
    positive_ratio = emotion_summary.get('긍정', 0)
    negative_ratio = emotion_summary.get('부정', 0)

    # 감정 점수 (0-100)
    emotion_score = (positive_ratio - negative_ratio * 0.5) * 100
    emotion_score = max(0, min(100, emotion_score))

    # LSM 점수 (0-100)
    lsm_score_normalized = lsm_score * 100

    # 최종 점수
    health = (
        emotion_score * 0.4 +
        lsm_score_normalized * 0.3 +
        balance_score * 0.3
    )

    return round(health, 2)


def _extract_keywords(messages: list[dict]) -> list[str]:
    """
    간단한 키워드 추출 (TODO: 개선 필요)

    현재는 더미 구현. 추후 TF-IDF나 TextRank로 개선
    """
    # 임시 키워드
    return ['데이트', '영화', '맛집', '주말', '여행']


@router.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "ok", "service": "analysis"}

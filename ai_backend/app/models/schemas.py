from pydantic import BaseModel
from typing import Dict, Optional, Any, List
from datetime import datetime


# ===== Analysis Core Models =====

class LSMScore(BaseModel):
    lsm_score: float
    category_breakdown: Dict[str, float]


class TurnTakingAnalysis(BaseModel):
    balance_score: float
    turn_ratio: float
    avg_response_time: float
    interruption_rate: float


class EmotionScore(BaseModel):
    emotion: str
    confidence: float
    all_scores: Dict[str, float]
    voice_emotion: Optional[Dict[str, Any]] = None


# ===== API Request Models =====

class MessageAnalysisRequest(BaseModel):
    """단일 메시지 분석 요청"""
    content: str
    sender_id: Optional[str] = None
    couple_id: Optional[str] = None


class ConversationAnalysisRequest(BaseModel):
    """전체 대화 분석 요청"""
    couple_id: str
    messages: List[Dict[str, Any]]  # [{sender_id, content, timestamp}, ...]
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None


# ===== API Response Models =====

class MessageAnalysisResponse(BaseModel):
    """단일 메시지 분석 응답"""
    message_id: Optional[str] = None
    emotion: EmotionScore
    topics: List[str]
    processed_at: datetime


class ConversationAnalysisResponse(BaseModel):
    """전체 대화 분석 응답"""
    couple_id: str
    emotion_summary: Dict[str, float]  # {긍정: 0.6, 중립: 0.3, 부정: 0.1}
    lsm_score: LSMScore
    turn_taking: TurnTakingAnalysis
    keywords: List[str]
    relationship_health: float  # 0-100
    conflict_detected: bool
    conflict_intensity: Optional[float] = None
    processed_at: datetime

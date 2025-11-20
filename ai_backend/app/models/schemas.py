from pydantic import BaseModel
from typing import Dict, Optional, Any

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

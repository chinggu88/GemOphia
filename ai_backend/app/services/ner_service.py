import json
import logging
from datetime import datetime
from typing import List, Optional
import google.generativeai as genai
from pydantic import BaseModel

from ..core.config import get_settings

logger = logging.getLogger(__name__)

class NEREntity(BaseModel):
    type: str  # date, time, location, activity
    value: str
    confidence: float

class NERService:
    def __init__(self):
        settings = get_settings()
        if settings.gemini_api_key:
            genai.configure(api_key=settings.gemini_api_key)
            self.model = genai.GenerativeModel('gemini-1.5-flash')
        else:
            logger.warning("GEMINI_API_KEY not set. NER service disabled.")
            self.model = None

    async def extract_entities(self, text: str) -> List[NEREntity]:
        """
        텍스트에서 날짜, 시간, 장소, 활동 정보를 추출합니다.
        """
        if not self.model:
            return []

        prompt = f"""
        다음 텍스트에서 일정과 관련된 주요 정보(날짜, 시간, 장소, 활동)를 추출해주세요.
        
        텍스트: "{text}"
        
        다음 JSON 형식으로만 응답해주세요:
        [
            {{"type": "date", "value": "2023-12-25", "confidence": 0.9}},
            {{"type": "time", "value": "19:00", "confidence": 0.8}},
            {{"type": "location", "value": "강남역", "confidence": 0.9}},
            {{"type": "activity", "value": "저녁 식사", "confidence": 0.7}}
        ]
        
        추출할 정보가 없으면 빈 리스트 [] 를 반환하세요.
        날짜는 가능한 YYYY-MM-DD 형식, 시간은 HH:MM 형식으로 변환해주세요.
        """

        try:
            response = self.model.generate_content(
                prompt,
                generation_config=genai.types.GenerationConfig(
                    temperature=0.1,
                    response_mime_type="application/json"
                )
            )
            
            entities_json = json.loads(response.text)
            entities = []
            
            for item in entities_json:
                entities.append(NEREntity(
                    type=item['type'],
                    value=item['value'],
                    confidence=item.get('confidence', 0.5)
                ))
                
            return entities

        except Exception as e:
            logger.error(f"Error extracting entities: {e}")
            return []

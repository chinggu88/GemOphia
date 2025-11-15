"""
Emotion Analysis Service - Modular Design
Supports multiple AI providers: Gemini, OpenAI, Claude
"""
from abc import ABC, abstractmethod
from typing import Literal
import json
import google.generativeai as genai
from ..core.config import get_settings
from ..models.schemas import EmotionScore


# ===== Abstract Base Class =====

class BaseEmotionAnalyzer(ABC):
    """Base class for emotion analyzers"""

    EMOTIONS = ["기쁨", "슬픔", "화남", "불안", "중립", "사랑", "피곤"]

    @abstractmethod
    async def analyze_emotion(self, text: str) -> EmotionScore:
        """Analyze emotion of the given text"""
        pass


# ===== Gemini Implementation =====

class GeminiEmotionAnalyzer(BaseEmotionAnalyzer):
    """Gemini API를 사용한 감정 분석"""

    def __init__(self, api_key: str):
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-1.5-flash')  # 가장 빠르고 저렴

    async def analyze_emotion(self, text: str) -> EmotionScore:
        """Gemini를 사용한 감정 분석"""

        prompt = f"""다음 한국어 텍스트의 감정을 분석해주세요.

텍스트: "{text}"

다음 7가지 감정에 대해 0~1 사이의 점수를 매겨주세요:
- 기쁨: 행복, 즐거움, 기쁨
- 슬픔: 슬픔, 우울, 외로움
- 화남: 화, 짜증, 분노
- 불안: 걱정, 불안, 긴장
- 중립: 평범함, 사실 전달
- 사랑: 애정, 사랑, 호감
- 피곤: 피곤함, 지침, 무기력

반드시 아래 JSON 형식으로만 응답해주세요 (다른 텍스트 없이):
{{
  "기쁨": 0.0,
  "슬픔": 0.0,
  "화남": 0.0,
  "불안": 0.0,
  "중립": 0.0,
  "사랑": 0.0,
  "피곤": 0.0
}}"""

        response = self.model.generate_content(
            prompt,
            generation_config=genai.types.GenerationConfig(
                temperature=0.3,
            )
        )

        # Parse JSON response
        response_text = response.text.strip()

        # Remove markdown code blocks if present
        if response_text.startswith("```json"):
            response_text = response_text.replace("```json", "").replace("```", "").strip()
        elif response_text.startswith("```"):
            response_text = response_text.replace("```", "").strip()

        scores = json.loads(response_text)

        # Find dominant emotion
        dominant_emotion = max(scores.items(), key=lambda x: x[1])

        return EmotionScore(
            emotion=dominant_emotion[0],
            confidence=dominant_emotion[1],
            all_scores=scores
        )


# ===== OpenAI Implementation (Optional) =====

class OpenAIEmotionAnalyzer(BaseEmotionAnalyzer):
    """OpenAI GPT를 사용한 감정 분석"""

    def __init__(self, api_key: str):
        from openai import OpenAI
        self.client = OpenAI(api_key=api_key)

    async def analyze_emotion(self, text: str) -> EmotionScore:
        """OpenAI GPT를 사용한 감정 분석"""

        prompt = f"""다음 한국어 텍스트의 감정을 분석해주세요.

텍스트: "{text}"

다음 7가지 감정에 대해 0~1 사이의 점수를 매겨주세요:
기쁨, 슬픔, 화남, 불안, 중립, 사랑, 피곤

JSON 형식으로만 응답:
{{"기쁨": 0.0, "슬픔": 0.0, "화남": 0.0, "불안": 0.0, "중립": 0.0, "사랑": 0.0, "피곤": 0.0}}"""

        response = self.client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "당신은 한국어 감정 분석 전문가입니다. JSON 형식으로만 응답하세요."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.3,
            response_format={"type": "json_object"}
        )

        scores = json.loads(response.choices[0].message.content)
        dominant_emotion = max(scores.items(), key=lambda x: x[1])

        return EmotionScore(
            emotion=dominant_emotion[0],
            confidence=dominant_emotion[1],
            all_scores=scores
        )


# ===== Claude Implementation (Optional) =====

class ClaudeEmotionAnalyzer(BaseEmotionAnalyzer):
    """Claude API를 사용한 감정 분석"""

    def __init__(self, api_key: str):
        from anthropic import Anthropic
        self.client = Anthropic(api_key=api_key)

    async def analyze_emotion(self, text: str) -> EmotionScore:
        """Claude를 사용한 감정 분석"""

        prompt = f"""다음 한국어 텍스트의 감정을 분석해주세요.

텍스트: "{text}"

다음 7가지 감정에 대해 0~1 사이의 점수를 매겨주세요:
기쁨, 슬픔, 화남, 불안, 중립, 사랑, 피곤

JSON 형식으로만 응답:
{{"기쁨": 0.0, "슬픔": 0.0, "화남": 0.0, "불안": 0.0, "중립": 0.0, "사랑": 0.0, "피곤": 0.0}}"""

        response = self.client.messages.create(
            model="claude-3-5-haiku-20241022",
            max_tokens=300,
            temperature=0.3,
            messages=[{"role": "user", "content": prompt}]
        )

        content = response.content[0].text.strip()
        scores = json.loads(content)
        dominant_emotion = max(scores.items(), key=lambda x: x[1])

        return EmotionScore(
            emotion=dominant_emotion[0],
            confidence=dominant_emotion[1],
            all_scores=scores
        )


# ===== Factory Function =====

def get_emotion_analyzer(
    provider: Literal["gemini", "openai", "anthropic"] | None = None
) -> BaseEmotionAnalyzer:
    """
    Factory function to get emotion analyzer based on provider

    Args:
        provider: AI provider name. If None, uses config setting.

    Returns:
        BaseEmotionAnalyzer: Emotion analyzer instance
    """
    settings = get_settings()
    provider = provider or settings.ai_provider

    if provider == "gemini":
        if not settings.gemini_api_key:
            raise ValueError("GEMINI_API_KEY not set in environment")
        return GeminiEmotionAnalyzer(settings.gemini_api_key)

    elif provider == "openai":
        if not settings.openai_api_key:
            raise ValueError("OPENAI_API_KEY not set in environment")
        return OpenAIEmotionAnalyzer(settings.openai_api_key)

    elif provider == "anthropic":
        if not settings.anthropic_api_key:
            raise ValueError("ANTHROPIC_API_KEY not set in environment")
        return ClaudeEmotionAnalyzer(settings.anthropic_api_key)

    else:
        raise ValueError(f"Unknown provider: {provider}")


# ===== Convenience Function =====

async def analyze_text_emotion(text: str, provider: str | None = None) -> EmotionScore:
    """
    Analyze emotion of text using configured provider

    Usage:
        result = await analyze_text_emotion("오늘 정말 행복해!")
        print(result.emotion)  # "기쁨"
        print(result.confidence)  # 0.89
    """
    analyzer = get_emotion_analyzer(provider)
    return await analyzer.analyze_emotion(text)

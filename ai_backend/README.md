# GemOphia AI 백엔드

커플 관계 분석을 위한 AI 백엔드

## 🚀 주요 기능

- **Realtime 메시지 분석**: Supabase Realtime으로 새 메시지 자동 감지 및 분석
- **감정 분석**: Gemini AI를 활용한 한국어 텍스트 감정 분석
- **LSM (Language Style Matching)**: 대화 스타일 유사도 분석
- **턴테이킹 분석**: 대화 균형 및 역학 분석
- **모듈화 설계**: AI 제공자 손쉽게 교체 가능 (Gemini, OpenAI, Claude)

## 📋 기술 스택

- **메인**: Realtime Listener (독립 Python 프로세스)
- **API (선택)**: FastAPI (수동 분석 API 필요시)
- **AI 제공자**: Google Gemini (기본값)
- **NLP**: Kiwipiepy (한국어 형태소 분석기)
- **데이터베이스**: Supabase (PostgreSQL + Realtime)
- **언어**: Python 3.11+

## 🛠️ 설치 및 실행

### 1. 가상환경 생성

```bash
cd ai_backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
```

### 2. 의존성 설치

```bash
pip install -r requirements.txt
```

### 3. 환경 변수 설정

`.env.example` 파일을 복사하여 `.env` 파일 생성:

```bash
cp .env.example .env
```

필수 환경 변수:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-service-role-key  # ⚠️ SERVICE_ROLE_KEY 사용!
GEMINI_API_KEY=your-gemini-api-key
```

**중요:** `SUPABASE_KEY`는 **SERVICE_ROLE_KEY**를 사용해야 합니다!
- Supabase Dashboard → Settings → API → `service_role` (secret)

### 4. Realtime Listener 실행 (메인)

```bash
python listener.py
```

실행되면:
```
================================================================================
🚀 GemOphia Realtime Listener Starting...
================================================================================
✅ Realtime Listener is now running!
   Listening for new messages in 'messages' table...
```

종료: `Ctrl+C`

### 5. (선택사항) FastAPI 서버 실행

수동 분석 API가 필요한 경우:

```bash
python -m app.main
```

서버 접속: `http://localhost:8000`

## 📚 API 엔드포인트

### 헬스 체크
```bash
GET /
GET /health
GET /api/v1/analysis/health
```

### 단일 메시지 분석
```bash
POST /api/v1/analysis/message
Content-Type: application/json

{
  "couple_id": "uuid",
  "sender_id": "uuid",
  "content": "오늘 정말 행복해!"
}
```

응답 예시:
```json
{
  "emotion": {
    "emotion": "기쁨",
    "confidence": 0.89,
    "all_scores": {
      "기쁨": 0.89,
      "슬픔": 0.02,
      "화남": 0.01,
      "불안": 0.02,
      "중립": 0.03,
      "사랑": 0.02,
      "피곤": 0.01
    }
  },
  "topics": [],
  "processed_at": "2025-01-14T10:30:00"
}
```

### 대화 분석
```bash
POST /api/v1/analysis/conversation
Content-Type: application/json

{
  "couple_id": "uuid",
  "messages": [
    {
      "sender_id": "user1",
      "content": "오늘 저녁 뭐 먹을까?",
      "timestamp": "2025-01-14T19:00:00"
    },
    {
      "sender_id": "user2",
      "content": "파스타 어때?",
      "timestamp": "2025-01-14T19:01:30"
    }
  ]
}
```

응답 예시:
```json
{
  "couple_id": "uuid",
  "emotion_summary": {
    "긍정": 0.65,
    "중립": 0.25,
    "부정": 0.10
  },
  "lsm_score": {
    "lsm_score": 0.78,
    "category_breakdown": {...}
  },
  "turn_taking": {
    "balance_score": 95.0,
    "turn_ratio": 0.475,
    "avg_response_time": 90.0
  },
  "keywords": ["데이트", "영화", "맛집"],
  "relationship_health": 82.5,
  "conflict_detected": false
}
```

## 🔧 AI 제공자 변경하기

감정 분석기는 모듈화되어 있어 쉽게 교체할 수 있습니다.

### 방법 1: 환경 변수로 변경
```env
AI_PROVIDER=openai  # 또는 anthropic
OPENAI_API_KEY=sk-...
```

### 방법 2: 추가 라이브러리 설치
```bash
# OpenAI 사용 시
pip install openai==1.54.0

# Claude 사용 시
pip install anthropic==0.39.0
```

`app/services/emotion_analyzer.py`에서 해당 import 주석 해제.

## 📁 프로젝트 구조

```
ai_backend/
├── app/
│   ├── api/
│   │   └── v1/
│   │       └── analysis.py      # API 엔드포인트
│   ├── services/
│   │   ├── emotion_analyzer.py  # 감정 분석 (모듈화)
│   │   ├── lsm_analyzer.py      # LSM 계산
│   │   └── turn_taking_analyzer.py  # 턴테이킹 분석
│   ├── models/
│   │   └── schemas.py           # Pydantic 모델
│   ├── core/
│   │   ├── config.py            # 설정
│   │   └── supabase.py          # Supabase 클라이언트
│   └── main.py                  # FastAPI 앱
├── requirements.txt
├── .env.example
└── README.md
```

## 🧪 테스트

```bash
# API 테스트 (curl)
curl http://localhost:8000/

# 감정 분석 테스트
curl -X POST http://localhost:8000/api/v1/analysis/message \
  -H "Content-Type: application/json" \
  -d '{
    "couple_id": "test",
    "sender_id": "user1",
    "content": "오늘 너무 행복해!"
  }'
```

## 🚀 다음 단계

- [ ] 주제 모델링 추가 (sentence-transformers 사용)
- [ ] 갈등 감지 구현 (LSTM 기반)
- [ ] 캐싱 레이어 추가 (Redis)
- [ ] Supabase 통합 (분석 결과 저장)
- [ ] 배치 분석 엔드포인트 추가
- [ ] 자체 KoBERT 모델 학습

## 📝 참고사항

- 현재 구현은 AI API 사용 (기본값: Gemini)
- 향후: 자체 학습 KoBERT 모델로 전환하여 비용 절감 예정
- LSM 및 턴테이킹은 규칙 기반 (API 호출 불필요)

## 💡 사용 예시

### Python에서 직접 호출
```python
from app.services.emotion_analyzer import analyze_text_emotion

# 감정 분석
result = await analyze_text_emotion("오늘 정말 행복해!")
print(result.emotion)      # "기쁨"
print(result.confidence)   # 0.89
```

### Flutter에서 HTTP 호출
```dart
final response = await http.post(
  Uri.parse('http://localhost:8000/api/v1/analysis/message'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'couple_id': coupleId,
    'sender_id': userId,
    'content': '오늘 정말 행복해!',
  }),
);

final result = jsonDecode(response.body);
print(result['emotion']['emotion']);  // "기쁨"
```

## 🔒 보안

- API 키는 절대 코드에 포함하지 마세요
- `.env` 파일은 `.gitignore`에 포함됨
- 프로덕션에서는 HTTPS 필수
- CORS 설정 확인 필요

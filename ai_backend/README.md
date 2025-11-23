# GemOphia AI 백엔드

> **퐁당** - AI 기반 커플 관계 관리 플랫폼

음성대화와 텍스트 데이터를 활용한 자연어 처리 기술로 사용자들의 대화 내용을 체계적으로 관리하여 **정보 기록 · 일정 자동 등록 · 대화 주제 제안 및 관계 심화 활동을 생성**하는 AI 기반 종합 관계 관리 플랫폼입니다.

## 📖 프로젝트 개요

### 문제 정의

현대 사회에서 커플 간의 관계 문제는 심각한 사회적 이슈로 대두되고 있습니다:

- **이별의 원인 1위**: '의사소통의 부재' (빙햄튼 대학, 2015)
- **결혼생활 만족도**: 기혼자의 31%가 보통 이하의 만족도 (통계청, 2024)
- **배우자 의사소통 만족도**: 49.9% (국가정책연구포털)
- **미래 전망**: 한국인의 65%가 '10년 후 연애·결혼이 더 어려워질 것'으로 응답 (Ipsos, 32개국 중 1위)

### 해결 방안

| 문제점 | 기존 방법 | AI 솔루션 |
|--------|----------|-----------|
| 관계 관리 | 개인 기억 의존 | 자동 기록 및 리마인더 |
| 대화 깊이 | 일상 대화 반복 | LLM 기반 대화 주제 제안 |
| 의사소통 | 사후 대응 | 실시간 감정 모니터링 |
| 추억 관리 | 분산 저장 | 통합 아카이빙 |

## 🚀 주요 기능

### 1. 정보 관리 시스템
- **음성/텍스트 입력 처리**: STT (Speech-to-Text) 기반 음성 인식
- **개체명 인식 (NER)**: 날짜, 장소, 활동 정보 자동 추출
- **키워드 추출**: LLM API를 활용한 대화 핵심 주제 파악

### 2. 스마트 일정 관리
- **자동 일정 인식 및 등록**: 자연스러운 대화에서 일정 자동 생성
- **한국 특화 기념일 관리**: 100일, 200일, 1000일 자동 계산 및 알림
- **음력 생일 지원**: 전통적인 기념일 정확한 관리
- **계절별 이벤트 추천**: 벚꽃, 단풍 시즌 등 알림

### 3. 대화 분석 엔진
- **멀티모달 감정 분석**: 음성 톤 + 텍스트 의미 융합 분석
  - 7가지 감정 분류: 기쁨, 슬픔, 화남, 불안, 중립, 사랑, 피곤
  - KoBERT 기반 한국어 특화 모델 (F1-score 0.87 목표)
- **대화 요약 생성**: KoBART 기반 추상적 요약

- **Realtime 메시지 분석**: Supabase Realtime으로 새 메시지 자동 감지 및 분석
- **감정 분석**: Gemini AI를 활용한 한국어 텍스트 감정 분석

- **LSM (Language Style Matching)**: 대화 스타일 유사도 분석
- **턴테이킹 분석**: 대화 균형 및 역학 분석

### 4. 관계 깊이 확장 시스템 (LLM 기반)
- **맞춤형 대화 주제 생성**: GPT-4를 활용한 관계 단계별 주제 제안
- **관계 발전 활동 추천**: 서로를 더 깊이 알아갈 수 있는 활동 제안
- **대화 가이드 제공**: 핵심 질문 + 세부 질문 구조화

### 5. 예방적 관계 케어
- **감정 트렌드 분석**: 주간/월간 감정 변화 추이 시각화
- **조기 경고 시스템**: 부정적 패턴 감지 및 개선 활동 제안
- **관계 성장 가이드**: 단계별 의사소통 방법 제안

## 📊 활용 데이터셋

| 데이터명 | 분야 | 출처 |
|---------|------|------|
| 감성 및 발화 스타일별 음성합성 데이터 | 한국어 | AI Hub / 내부생성데이터 |
| 감성 대화 말뭉치 | 한국어 | AI Hub / 내부생성데이터 |
| 일정 및 캘린더 데이터 | 시계열 | 내부생성데이터 |
| 심리학 기반 질문 데이터베이스 | 심리 | 학술 연구 / 내부생성데이터 |

## 🧠 AI 모델 아키텍처

### 감정 분석 모델
- **기본 모델**: KoBERT (KAIST 14,606건 감정 레이블 데이터셋 fine-tuning)
- **앙상블 구성**: KoBERT + KoELECTRA + KcBERT
- **목표 성능**: F1-score 0.87 이상

### 대화 패턴 분석
- **아키텍처**: Transformer Encoder-Decoder
- **메커니즘**: Multi-head Self-Attention + LSTM
- **기능**: 시간에 따른 대화 패턴 및 감정 변화 추적

### LLM 통합 시스템
- **핵심 모델**: GPT-4 (대화 주제 생성, 관계 발전 활동 추천)
- **파이프라인**:
  1. 입력: 대화 히스토리 → 감정 분석 → 주제 분류 → 키워드 추출
  2. 프롬프트 구성: 분석 결과 + 관계 단계 정보 + 미탐색 주제
  3. 출력: JSON 구조화 (주제명, 핵심 질문, 대화 가이드, 예상 시간)

### 최적화 전략
- **지식증류**: 대형 모델 → 경량 모델 (1/3 크기, 최소 성능 저하)
- **양자화**: FP16 혼합 정밀도 연산 (2배 속도 향상)
- **캐싱**: Redis 기반 결과 캐싱 (응답시간 90% 단축)
- **배치 처리**: GPU 활용도 극대화

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

## 🔒 보안 및 프라이버시

### 보안 아키텍처
- **데이터 암호화**: End-to-End 암호화 방식
- **엣지 처리**: 사용자 디바이스에서 음성 전처리 및 로컬 암호화
- **서버 보안**: 암호화된 데이터만 전송

### 프라이버시 보호 기술
- **연합학습 (Federated Learning)**: 개인 데이터를 서버로 전송하지 않고 모델 학습
- **차분 프라이버시 (Differential Privacy)**: 개인 식별 불가하도록 노이즈 추가
- **동형 암호화 (Homomorphic Encryption)**: 암호화 상태에서 연산 수행

### 기본 보안 수칙
- API 키는 절대 코드에 포함하지 마세요
- `.env` 파일은 `.gitignore`에 포함됨
- 프로덕션에서는 HTTPS 필수
- CORS 설정 확인 필요

## 📈 기대효과 및 성과 목표

### 정량적 성과 목표

| 지표 | 목표 | 측정 방법 |
|------|------|----------|
| 사용자 만족도 | 4.5점 이상 | NPS (Net Promoter Score) |
| 일정 등록 자동화율 | 80% 이상 | 음성 인식 기반 일정 생성 성공률 |
| 새로운 주제 탐색 | 월 8개 이상 | 주제 다양성 분석 |
| 활동 실행률 | 70% 이상 | AI 제안 활동 실제 실행 비율 |
| 관계 만족도 향상 | 25% 이상 | 분기별 설문 (사용 전후 비교) |

### 사회적 가치

#### 직접적 효과
- **의사소통 개선**: AI 기반 대화 패턴 분석으로 소통 품질 향상
- **관계 깊이 강화**: LLM 기반 대화 주제 제안으로 상호 이해도 증가
- **정서적 유대 강화**: 관계 발전 활동 추천으로 의미 있는 경험 공유

#### 간접적 효과
- **저출산 문제 해결 기여**: 안정적인 커플 관계 → 결혼/출산 의향 증가
- **정신건강 개선**: 예방적 관계 케어로 갈등 스트레스 감소
- **디지털 포용 촉진**: AI 기술의 일상 적용 사례 확대

## 🔬 시장 검증

### 글로벌 사례
- **TimeTree (일본)**: 공유 캘린더 앱, 전 세계 5천만+ 사용자
- **Between (한국)**: 커플 앱, 전 세계 3,200만+ 커플 사용

### 국내 검증
- **서울시 '설렘, in 한강'**: 33:1 경쟁률, 54% 매칭률 달성

## 📚 참고문헌

- 통계청, "2024년 사회조사 결과", 2024.11
- Morris, C. E., Reiber, C., & Roman, E. (2015). Quantitative sex differences in response to the dissolution of a romantic relationship. Binghamton University.
- 국가정책연구포털, "장년기 및 노년기 가족관계 실태조사", 한국여성정책연구원
- Ipsos, "Global Views on Love, Dating, and Marriage", 32개국 조사, 2023

---

**Team GemOphiaLab** | 2025 SeSAC Hackathon

# GemOphia Supabase Edge Functions

커플 관계 분석을 위한 서버리스 함수들

## 📁 구조

```
supabase/functions/
├── analyze-message/        # 단일 메시지 감정 분석
│   └── index.ts           # Gemini API 기반 감정 분석
├── analyze-conversation/   # 대화 전체 분석 (TODO)
│   └── index.ts           # LSM + 턴테이킹 분석
└── _shared/               # 공통 라이브러리 (TODO)
    ├── lsm-analyzer.ts
    └── turn-taking-analyzer.ts
```

## ✅ 완료된 기능

### analyze-message
- ✅ Gemini API 연동
- ✅ 7가지 감정 분석 (기쁨, 슬픔, 화남, 불안, 중립, 사랑, 피곤)
- ✅ 상세 주석 (Python 개발자를 위한 설명)
- ✅ CORS 설정
- ✅ 에러 처리

## 🔜 TODO

- [ ] analyze-conversation 함수 구현
- [ ] LSM Analyzer TypeScript 포팅
- [ ] Turn Taking Analyzer TypeScript 포팅
- [ ] 주제 추출 기능 추가
- [ ] 배치 분석 엔드포인트

## 🚀 배포 방법

### 1. Supabase 프로젝트 연결

```bash
# 프로젝트 연결 (한 번만)
supabase link --project-ref your-project-ref
```

### 2. 환경 변수 설정

```bash
# GEMINI_API_KEY 설정
supabase secrets set GEMINI_API_KEY=your-api-key
```

### 3. 함수 배포

```bash
# 특정 함수 배포
supabase functions deploy analyze-message

# 모든 함수 배포
supabase functions deploy
```

## 🧪 로컬 테스트 (Docker 필요)

### Docker Desktop 설치 후

```bash
# 함수 실행
supabase functions serve analyze-message --env-file .env

# 테스트 요청
curl -i --location --request POST 'http://localhost:54321/functions/v1/analyze-message' \
  --header 'Content-Type: application/json' \
  --data '{
    "couple_id": "test",
    "sender_id": "user1",
    "content": "오늘 정말 행복해!"
  }'
```

## 📝 API 사용법

### analyze-message

**Endpoint:**
```
POST https://your-project.supabase.co/functions/v1/analyze-message
```

**Request:**
```json
{
  "couple_id": "uuid",
  "sender_id": "uuid",
  "content": "오늘 정말 행복해!"
}
```

**Response:**
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
  "processed_at": "2025-01-16T10:30:00.000Z"
}
```

## 🔧 기술 스택

- **런타임**: Deno (Edge Runtime)
- **언어**: TypeScript
- **AI API**: Google Gemini (gemini-1.5-flash)
- **플랫폼**: Supabase Edge Functions

## 📚 Python vs TypeScript

이 프로젝트는 Python FastAPI에서 TypeScript Edge Functions로 전환 중입니다.

| Python (기존) | TypeScript (현재) |
|--------------|------------------|
| FastAPI 서버 | 서버리스 함수 |
| 서버 관리 필요 | 자동 스케일링 |
| kiwipiepy | (형태소 분석 제거) |
| os.getenv() | Deno.env.get() |
| async def | async function |

## 📖 학습 자료

TypeScript 주석이 상세하게 달려있어 Python 개발자도 쉽게 이해할 수 있습니다.

각 함수의 `index.ts` 파일을 확인하세요!

## 🔒 보안

- API 키는 Supabase Secrets로 관리
- `.env` 파일은 `.gitignore`에 포함
- CORS 설정 확인 필요 (현재는 모든 출처 허용)

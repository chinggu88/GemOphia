# 퐁당(PONGDANG) 프로토타입 구현 로드맵 v2.0

> **프로토타입 MVP 개발 계획 (하이브리드 아키텍처)**
> AI 기반 종합 관계 관리 플랫폼 - GemOphiaLab
>
> **Updated**: 2025-11-19 - 기존 테이블 활용 + AI 전용 테이블 추가
>
> ⚠️ **이 문서는 프로토타입 개발 계획입니다**
> - 원본 기획서: `PLANNING.md` (최종 프로덕션 목표)
> - 이 문서: 빠른 MVP 검증을 위한 프로토타입 구현 계획

---

## 📋 목차

1. [프로토타입 vs 프로덕션](#프로토타입-vs-프로덕션)
2. [현재 상황](#현재-상황)
3. [전체 시스템 아키텍처](#전체-시스템-아키텍처)
4. [데이터베이스 설계](#데이터베이스-설계)
5. [MVP Phase 0: 기반 보완](#mvp-phase-0-기반-보완)
6. [MVP Phase 1: 기본 대화 분석](#mvp-phase-1-기본-대화-분석)
7. [MVP Phase 2: 스마트 일정 관리](#mvp-phase-2-스마트-일정-관리)
8. [MVP Phase 3: 관계 깊이 확장](#mvp-phase-3-관계-깊이-확장)
9. [MVP Phase 4: 예방적 관계 케어](#mvp-phase-4-예방적-관계-케어)
10. [성능 최적화 및 보안](#성능-최적화-및-보안)

---

## 프로토타입 vs 프로덕션

### 🎯 프로토타입 개발 목표

1. **빠른 MVP 검증**
   - API 기반 빠른 구현으로 2-3주 내 프로토타입 완성
   - 핵심 기능의 실제 작동 여부 검증
   - 사용자 피드백 조기 수집

2. **비즈니스 모델 검증**
   - 사용자 반응 테스트
   - 정량적 목표 달성 가능성 확인
   - 시장 수요 검증

3. **기술적 타당성 확인**
   - 하이브리드 아키텍처 검증
   - Realtime Listener 패턴 안정성 테스트
   - AI 분석 정확도 초기 평가

### 🔄 기술 스택 차이

| 기능 | 프로토타입 (현재) | 프로덕션 (PLANNING.md 목표) | 전환 시점 |
|------|------------------|----------------------------|----------|
| **감정 분석** | Gemini API | KoBERT 자체 학습 (F1 0.87) | 사용자 1,000명 |
| **NER** | Gemini/GPT-4 LLM API | KoBERT 기반 NER | 사용자 1,000명 |
| **대화 요약** | Gemini API | KoBART | Phase 2 |
| **주제 생성** | GPT-4 | GPT-4 (유지) | - |
| **활동 추천** | GPT-4 | GPT-4 (유지) | - |
| **STT** | Whisper API | Whisper (로컬) | Phase 3 |

### 📊 프로토타입 vs 프로덕션 비교

#### 프로토타입 장점
- ✅ **빠른 구현**: API 사용으로 2-3주 내 MVP 완성
- ✅ **낮은 초기 비용**: 인프라 구축 불필요
- ✅ **높은 정확도**: 최신 LLM 활용
- ✅ **유연한 변경**: API 파라미터 조정만으로 개선 가능

#### 프로토타입 단점
- ❌ **API 비용**: 사용량 증가 시 비용 급증
- ❌ **응답 속도**: 네트워크 지연
- ❌ **커스터마이징 한계**: API 제공 기능에 제한됨

#### 프로덕션 장점
- ✅ **비용 절감**: 자체 모델로 월 비용 90% 절감
- ✅ **빠른 응답**: 로컬 모델 추론 (100ms 이내)
- ✅ **데이터 프라이버시**: 외부 API 의존도 제거
- ✅ **커스터마이징**: 한국어/커플 대화에 특화된 파인튜닝

#### 프로덕션 단점
- ❌ **개발 시간**: 모델 학습 및 최적화에 2-3개월
- ❌ **초기 투자**: GPU 인프라 구축 비용
- ❌ **유지보수**: 모델 재학습 및 성능 관리 필요

### 🚀 전환 계획

**Phase 1: 프로토타입 검증** (현재)
- Gemini/GPT-4 API 100% 활용
- 목표: 사용자 100명, 피드백 수집

**Phase 2: 부분 전환** (사용자 1,000명 달성 시)
- 감정 분석 → KoBERT 전환
- NER → KoBERT NER 전환
- 비용 절감 효과: 약 60%

**Phase 3: 완전 전환** (정식 출시 후)
- 모든 API → 자체 모델
- Whisper API → 로컬 Whisper
- 비용 절감 효과: 약 90%

### 💡 왜 프로토타입에서 API를 사용하는가?

1. **시간 = 기회비용**
   - KoBERT 학습 및 최적화: 2-3개월
   - Gemini API 연동: 1-2일
   - 빠른 검증이 시장 진입에 유리

2. **불확실성 제거**
   - 사용자가 실제로 사용할지 미지수
   - 비즈니스 모델 검증 필요
   - 프로토타입으로 검증 후 투자 결정

3. **기술 검증**
   - 하이브리드 아키텍처 작동 확인
   - Realtime Listener 안정성 테스트
   - 데이터베이스 설계 검증

---

## 현재 상황

### ✅ 이미 구축된 시스템

```
[기존 Flutter 앱 + Supabase]
- conversations 테이블 (대화 메시지)
- couples 테이블 (커플 정보)
- profiles 테이블 (사용자 프로필)
- schedules 테이블 (일정)
- todos 테이블 (할일)
```

### 🎯 추가할 AI 시스템

```
[AI 백엔드 + AI 전용 테이블]
- analysis_results (감정 분석)
- conversation_analysis (일별 종합 분석)
- ner_extractions (NER 결과)
- anniversaries (기념일)
- conversation_topics (LLM 대화 주제)
- activities (관계 발전 활동)
- emotion_trends (감정 트렌드)
- relationship_health (관계 건강도)
... 총 12개
```

### 🔑 핵심 설계 원칙

1. **기존 시스템 최소 변경**
   - ✅ 기존 Flutter 앱 로직 수정 금지 (선택적 활용만)
   - ⚠️ **예외**: Phase 0에서 conversations 테이블에 AI 기능을 위한 최소한의 컬럼 추가
     - message_type, audio_url, voice_tone_features, sentiment, emotion_score
     - 모두 선택적(NULL 허용 or DEFAULT), 기존 기능에 영향 없음
   - ✅ AI 전용 테이블은 외래키로만 연결, 독립적으로 관리

2. **하이브리드 아키텍처**
   - Flutter → Supabase (기존 방식 유지)
   - AI 백엔드는 Realtime Listener로 동작
   - 양방향 실시간 통신

3. **점진적 확장**
   - Phase별 독립 배포
   - AI 기능 하나씩 추가

---

## 전체 시스템 아키텍처

### 🏗️ 하이브리드 아키텍처 다이어그램

```
┌─────────────────────────────────────────────────────────────────┐
│                      Flutter 앱 (퐁당)                            │
│                                                                   │
│  사용자 입력:                                                      │
│  ├─ 텍스트 메시지 ────────────────────┐                           │
│  └─ 음성 메시지 (녹음) ──────────┐    │                           │
└────────────────────────────────│────│───────────────────────────┘
                                 │    │
                          ┌──────┘    └──────┐
                          │                  │
                          v                  v
                 ┌─────────────────┐  ┌──────────────┐
                 │ Supabase        │  │conversations │
                 │ Storage         │  │테이블 INSERT  │
                 │ (음성 파일 업로드)│  │             │
                 └─────────────────┘  └──────────────┘
                          │                  │
                          │ audio_url        │
                          └────────┬─────────┘
                                   │
                                   v
                        ┌──────────────────────┐
                        │ Supabase Realtime    │
                        │ (PostgreSQL Trigger) │
                        └──────────────────────┘
                                   │
                                   │ 새 메시지 감지!
                                   │
                                   v
┌─────────────────────────────────────────────────────────────────┐
│              AI 백엔드 (독립 Python 프로세스)                      │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Realtime Listener (24/7 실행)                              │ │
│  │  ├─ conversations 테이블 구독                                │ │
│  │  └─ 새 메시지 감지 → 파이프라인 실행                         │ │
│  └────────────────────────────────────────────────────────────┘ │
│         │                                                         │
│         v                                                         │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  📝 전처리 파이프라인                                         │ │
│  │  ├─ message_type == 'voice' ?                               │ │
│  │  │   ├─ YES → Supabase Storage에서 다운로드                  │ │
│  │  │   │        → STT (Whisper)                               │ │
│  │  │   │        → conversations.content 업데이트               │ │
│  │  │   └─ NO  → content 그대로 사용                            │ │
│  │  └─ 텍스트 정규화                                             │ │
│  └────────────────────────────────────────────────────────────┘ │
│         │                                                         │
│         v                                                         │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  🧠 AI 분석 파이프라인                                        │ │
│  │  ├─ NER (날짜, 장소, 활동 추출)                              │ │
│  │  │   → ner_extractions 테이블 INSERT                        │ │
│  │  ├─ 감정 분석 (Gemini API)                                   │ │
│  │  │   → analysis_results 테이블 INSERT                       │ │
│  │  └─ 키워드 추출 (TextRank)                                   │ │
│  │      → analysis_results.keywords 업데이트                    │ │
│  └────────────────────────────────────────────────────────────┘ │
│         │                                                         │
│         v                                                         │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  💾 결과 업데이트                                             │ │
│  │  └─ conversations 테이블 업데이트                             │ │
│  │      - sentiment: '기쁨'                                     │ │
│  │      - emotion_score: 89                                    │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                   │
                                   v
                        ┌──────────────────────┐
                        │ Supabase Realtime    │
                        │ (변경 감지)           │
                        └──────────────────────┘
                                   │
                                   v
┌─────────────────────────────────────────────────────────────────┐
│              Flutter 앱 (실시간 업데이트 수신)                     │
│                                                                   │
│  ├─ conversations 변경 감지                                       │
│  │   → UI 업데이트 (sentiment, emotion_score 표시)               │
│  └─ analysis_results 생성 감지                                   │
│      → 상세 감정 분석 결과 표시                                   │
└─────────────────────────────────────────────────────────────────┘
```

### 🔄 데이터 흐름 시나리오

#### 시나리오 1: 텍스트 메시지

```
[사용자] "다음 주 토요일 7시에 강남역에서 영화 보자"
   ↓
[Flutter] conversations.insert({
   content: "다음 주 토요일 7시에 강남역에서 영화 보자",
   message_type: "text",
   couple_id: "xxx",
   user_id: "yyy"
})
   ↓
[Supabase Realtime] → AI 백엔드 Listener 트리거
   ↓
[AI 백엔드]
   1. NER 추출
      → DATE: "다음 주 토요일" = "2025-11-29"
      → TIME: "7시" = "19:00"
      → LOCATION: "강남역"
      → ACTIVITY: "영화"
   2. ner_extractions 테이블 INSERT (4개 row)
   3. 감정 분석
      → emotion: "기쁨", confidence: 0.92
   4. analysis_results 테이블 INSERT
   5. conversations 테이블 UPDATE
      → sentiment: "기쁨", emotion_score: 92
   ↓
[Supabase Realtime] → Flutter 앱으로 변경 알림
   ↓
[Flutter] UI 업데이트
   - 메시지에 😊 이모지 표시
   - "일정을 자동으로 감지했어요!" 알림
```

#### 시나리오 2: 음성 메시지

```
[사용자] 음성 녹음 (3초)
   ↓
[Flutter]
   1. Supabase Storage 업로드
      → voice-messages/user-id/timestamp.m4a
   2. conversations.insert({
      content: null,  // 아직 STT 안 됨
      message_type: "voice",
      audio_url: "https://.../voice-messages/...",
      couple_id: "xxx",
      user_id: "yyy"
   })
   ↓
[Supabase Realtime] → AI 백엔드 Listener 트리거
   ↓
[AI 백엔드]
   1. message_type == 'voice' 확인
   2. Supabase Storage에서 음성 파일 다운로드
   3. STT (Whisper)
      → text: "오늘 진짜 재미있었어"
   4. conversations.content 업데이트
      → content: "오늘 진짜 재미있었어"
   5. 감정 분석 (text 기준)
      → emotion: "기쁨"
   6. 음성 톤 분석 (추가)
      → voice_emotion: {"tone": "excited", "speed": "fast"}
   7. analysis_results 테이블 INSERT
   8. conversations 테이블 UPDATE
      → sentiment: "기쁨", emotion_score: 95
   ↓
[Flutter]
   - 음성 메시지에 텍스트 자막 표시
   - 감정 분석 결과 표시
```

---

## 데이터베이스 설계

### 🗄️ 기존 테이블 (5개) - 수정 금지

```sql
✅ conversations  -- 대화 메시지 (Flutter 앱에서 사용 중)
✅ couples        -- 커플 정보
✅ profiles       -- 사용자 프로필
✅ schedules      -- 일정
✅ todos          -- 할일
```

### 🆕 AI 전용 테이블 (12개) - 새로 추가

```sql
[Phase 1: 대화 분석]
- analysis_results        -- 메시지별 감정 분석
- conversation_analysis   -- 일별 종합 분석

[Phase 2: 일정 관리]
- ner_extractions         -- NER 결과
- anniversaries           -- 기념일

[Phase 3: 관계 발전]
- conversation_topics     -- LLM 대화 주제
- topic_history           -- 주제 기록
- activities              -- 관계 발전 활동
- conversation_summaries  -- 일별 요약

[Phase 4: 트렌드 & 건강]
- emotion_trends          -- 감정 트렌드
- relationship_health     -- 관계 건강도
- conflict_alerts         -- 조기 경고
- user_preferences        -- 선호도 학습
```

**상세 스키마**: `AI_TABLES_SCHEMA.md` 참고

---

## MVP Phase 0: 기반 보완

**목표**: 기존 테이블 보완 + AI 인프라 구축
**소요 기간**: 2-3일

### ✅ 체크리스트

#### 1일차: conversations 테이블 스키마 확인 및 보완

**작업**:
1. Supabase Dashboard에서 conversations 테이블 스키마 확인
2. 필요한 컬럼이 있는지 체크:

```sql
-- 필수 컬럼 체크리스트
✓ id (UUID)
✓ couple_id (UUID)
✓ user_id (UUID)
✓ content (TEXT) -- 메시지 내용
? message_type (VARCHAR) -- 'text' or 'voice' (없으면 추가)
? audio_url (TEXT) -- Supabase Storage URL (없으면 추가)
? voice_tone_features (JSONB) -- 음성 특징 (선택)
? sentiment (VARCHAR) -- AI가 업데이트할 필드 (없으면 추가)
? emotion_score (INT) -- AI가 업데이트할 필드 (없으면 추가)
✓ created_at (TIMESTAMP)
```

3. 부족한 컬럼 추가 마이그레이션 작성:

```sql
-- supabase/migrations/20251119000001_enhance_conversations.sql

ALTER TABLE conversations
  ADD COLUMN IF NOT EXISTS message_type VARCHAR(20) DEFAULT 'text';

ALTER TABLE conversations
  ADD COLUMN IF NOT EXISTS audio_url TEXT;

ALTER TABLE conversations
  ADD COLUMN IF NOT EXISTS voice_tone_features JSONB;

ALTER TABLE conversations
  ADD COLUMN IF NOT EXISTS sentiment VARCHAR(50);

ALTER TABLE conversations
  ADD COLUMN IF NOT EXISTS emotion_score INT;

CREATE INDEX IF NOT EXISTS idx_conversations_message_type
  ON conversations(message_type);

CREATE INDEX IF NOT EXISTS idx_conversations_sentiment
  ON conversations(sentiment, created_at DESC);

COMMENT ON COLUMN conversations.message_type IS 'text 또는 voice';
COMMENT ON COLUMN conversations.audio_url IS 'Supabase Storage 음성 파일 URL';
COMMENT ON COLUMN conversations.sentiment IS 'AI 감정 분석 결과 (기쁨, 슬픔 등)';
COMMENT ON COLUMN conversations.emotion_score IS 'AI 감정 점수 (0-100)';
```

#### 2일차: Supabase Storage 설정

**작업**:
1. Supabase Dashboard → Storage → New Bucket
2. Bucket 이름: `voice-messages`
3. Public: `false` (비공개)

```sql
-- Storage RLS 정책

-- 사용자는 자신의 음성 파일만 업로드 가능
CREATE POLICY "Users can upload their own voice messages"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'voice-messages' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- 커플 상대방도 음성 파일 다운로드 가능
CREATE POLICY "Couple members can download voice messages"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'voice-messages' AND
  (
    auth.uid()::text = (storage.foldername(name))[1]
    OR
    auth.uid() IN (
      SELECT user_a_id FROM couples WHERE user_b_id = (storage.foldername(name))[1]::uuid
      UNION
      SELECT user_b_id FROM couples WHERE user_a_id = (storage.foldername(name))[1]::uuid
    )
  )
);
```

#### 3일차: AI 백엔드 환경 설정

**작업**:
- [ ] Python 가상환경 확인
- [ ] 의존성 설치
  ```bash
  cd ai_backend
  source venv/bin/activate
  pip install -r requirements.txt
  ```
- [ ] `.env` 파일 확인
  ```
  SUPABASE_URL=https://xxx.supabase.co
  SUPABASE_SERVICE_ROLE_KEY=xxx
  GEMINI_API_KEY=xxx
  OPENAI_API_KEY=xxx (Phase 3에서 사용)
  ```
- [ ] Realtime Listener 테스트
  ```bash
  python listener.py
  ```

### 📦 Phase 0 결과물

```
supabase/migrations/
└── 20251119000001_enhance_conversations.sql  ✅

Supabase Dashboard:
├── Storage Bucket: voice-messages  ✅
└── RLS 정책 적용  ✅

ai_backend/:
├── venv/ 활성화  ✅
├── .env 설정  ✅
└── listener.py 실행 가능  ✅
```

### 🎯 Phase 0 성공 기준
- ✅ conversations 테이블에 필요한 컬럼 모두 존재
- ✅ voice-messages Storage Bucket 생성 완료
- ✅ Realtime Listener가 conversations INSERT 감지 확인

---

## MVP Phase 1: 기본 대화 분석

**목표**: 감정 분석 + LSM + 턴테이킹
**소요 기간**: 5-7일
**기획서 근거**: 섹션 5 - (3) 대화 분석 엔진

### 🎯 핵심 기능

1. **멀티모달 감정 분석**
   - 텍스트: Gemini API
   - 음성: 톤 분석 (Phase 1.5)
   - 융합: 70% 텍스트 + 30% 음성

2. **대화 분석 지표**
   - LSM (Language Style Matching)
   - 턴테이킹 분석
   - 키워드 추출

### 📅 일정별 구현 계획

#### 1일차: Phase 1 마이그레이션 적용

**작업**:
```bash
# Supabase Dashboard → SQL Editor
# supabase/migrations/20251119100001_phase1_analysis_tables.sql 실행

# 또는
supabase db push
```

**확인**:
```sql
SELECT * FROM analysis_results LIMIT 1;
SELECT * FROM conversation_analysis LIMIT 1;
```

#### 2-3일차: Realtime Listener 파이프라인 구축

**파일**: `ai_backend/app/services/realtime_listener.py`

```python
async def handle_new_message(self, payload: Dict[str, Any]):
    """
    Phase 1 완전 구현

    파이프라인:
    1. 메시지 수신
    2. 음성이면 STT 처리
    3. NER 추출 (Phase 2 준비)
    4. 감정 분석
    5. analysis_results 저장
    6. conversations 업데이트
    """
    message = payload.get('record', {})
    message_id = message['id']
    message_type = message.get('message_type', 'text')

    # ============================================================
    # 1. 전처리: 음성 → 텍스트 변환
    # ============================================================
    if message_type == 'voice':
        audio_url = message.get('audio_url')

        if not audio_url:
            logger.warning(f"Voice message {message_id} has no audio_url")
            return

        # Supabase Storage에서 다운로드
        logger.info(f"Downloading audio from: {audio_url}")
        audio_data = await self.download_audio(audio_url)

        # STT (Whisper)
        logger.info(f"Running STT for message {message_id}")
        text = await stt_service.transcribe(audio_data)

        # 음성 특징 추출 (톤, 속도 등)
        voice_features = extract_voice_features(audio_data)

        # conversations 테이블 업데이트
        await self.supabase.table('conversations').update({
            'content': text,
            'voice_tone_features': voice_features
        }).eq('id', message_id).execute()

        logger.info(f"STT completed: {text[:50]}...")
        content = text
    else:
        content = message.get('content', '')
        voice_features = None

    if not content:
        logger.warning(f"Message {message_id} has no content")
        return

    # ============================================================
    # 2. 감정 분석 (Gemini API)
    # ============================================================
    logger.info(f"Analyzing emotion for message {message_id}")
    emotion_result = await emotion_analyzer.analyze_multimodal(
        text=content,
        voice_features=voice_features
    )

    # ============================================================
    # 3. 키워드 추출 (TextRank)
    # ============================================================
    keywords = await textrank_extractor.extract(content)

    # ============================================================
    # 4. analysis_results 테이블 저장
    # ============================================================
    analysis_data = {
        'conversation_id': message_id,
        'emotion': emotion_result.emotion,
        'confidence': float(emotion_result.confidence),
        'all_scores': emotion_result.all_scores,
        'voice_emotion': emotion_result.voice_emotion,
        'keywords': keywords,
        'topics': []  # Phase 3에서 구현
    }

    await self.supabase.table('analysis_results').insert(analysis_data).execute()

    # ============================================================
    # 5. conversations 테이블 업데이트
    # ============================================================
    await self.supabase.table('conversations').update({
        'sentiment': emotion_result.emotion,
        'emotion_score': int(emotion_result.confidence * 100)
    }).eq('id', message_id).execute()

    logger.info(
        f"✅ Analysis complete for {message_id}: "
        f"{emotion_result.emotion} ({emotion_result.confidence:.2f})"
    )

async def download_audio(self, audio_url: str) -> bytes:
    """Supabase Storage에서 음성 파일 다운로드"""
    # URL에서 bucket과 path 추출
    # audio_url 형식: "https://.../storage/v1/object/public/voice-messages/user-id/file.m4a"

    path = audio_url.split('/voice-messages/')[-1]

    # Storage에서 다운로드
    response = self.supabase.storage.from_('voice-messages').download(path)

    return response
```

**작업**:
- [ ] STT 서비스 구현 (`stt_service.py`)
- [ ] 음성 특징 추출 구현
- [ ] 멀티모달 감정 분석 구현 (`emotion_analyzer.py` 개선)
- [ ] TextRank 키워드 추출 구현
- [ ] Realtime Listener 파이프라인 통합

#### 4-5일차: 일별 배치 작업 구현

**파일**: `ai_backend/app/schedulers/daily_analysis.py`

```python
"""
매일 23:59 실행

작업:
1. 오늘의 대화 조회
2. LSM 분석
3. 턴테이킹 분석
4. 관계 건강도 계산
5. conversation_analysis 저장
"""

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from datetime import datetime, date

scheduler = AsyncIOScheduler()

@scheduler.scheduled_job('cron', hour=23, minute=59)
async def daily_conversation_analysis():
    """일별 대화 분석 배치"""
    today = date.today()

    logger.info(f"Starting daily analysis for {today}")

    # 모든 커플 조회
    couples_result = await supabase.table('couples').select('*').execute()
    couples = couples_result.data

    for couple in couples:
        try:
            await analyze_couple_day(couple['id'], today)
        except Exception as e:
            logger.error(f"Error analyzing couple {couple['id']}: {e}")

async def analyze_couple_day(couple_id: str, analysis_date: date):
    """특정 커플의 하루 대화 분석"""

    # 1. 오늘의 메시지 조회
    messages_result = await supabase.table('conversations')\
        .select('*')\
        .eq('couple_id', couple_id)\
        .gte('created_at', f'{analysis_date} 00:00:00')\
        .lt('created_at', f'{analysis_date} 23:59:59')\
        .execute()

    messages = messages_result.data

    if len(messages) < 2:
        logger.info(f"Couple {couple_id}: Not enough messages ({len(messages)})")
        return

    # 2. 감정 요약
    emotion_summary = calculate_emotion_summary(messages)
    dominant_emotion = max(emotion_summary, key=emotion_summary.get)

    # 3. LSM 분석
    lsm_result = await lsm_analyzer.analyze(couple_id, messages)

    # 4. 턴테이킹 분석
    turn_taking_result = await turn_taking_analyzer.analyze(messages)

    # 5. 관계 건강도 계산
    relationship_health = calculate_health_score(
        emotion_summary=emotion_summary,
        lsm_score=lsm_result.score,
        balance_score=turn_taking_result.balance_score
    )

    # 6. 갈등 감지
    conflict_detected = emotion_summary.get('부정', 0) > 0.3
    conflict_intensity = emotion_summary.get('부정', 0) if conflict_detected else 0.0

    # 7. 키워드 추출
    all_content = ' '.join([m['content'] for m in messages if m['content']])
    keywords = await textrank_extractor.extract(all_content, top_k=10)

    # 8. conversation_analysis 저장
    analysis_data = {
        'couple_id': couple_id,
        'analysis_date': str(analysis_date),
        'emotion_summary': emotion_summary,
        'dominant_emotion': dominant_emotion,
        'lsm_score': float(lsm_result.score),
        'lsm_details': lsm_result.details,
        'turn_taking': turn_taking_result.to_dict(),
        'relationship_health': float(relationship_health),
        'conflict_detected': conflict_detected,
        'conflict_intensity': float(conflict_intensity),
        'keywords': keywords
    }

    await supabase.table('conversation_analysis')\
        .upsert(analysis_data, on_conflict='couple_id,analysis_date')\
        .execute()

    logger.info(
        f"✅ Daily analysis complete for couple {couple_id}: "
        f"Health={relationship_health:.1f}, Conflict={conflict_detected}"
    )

def calculate_health_score(
    emotion_summary: dict,
    lsm_score: float,
    balance_score: float
) -> float:
    """
    관계 건강도 계산

    공식: 감정(40%) + LSM(30%) + 균형(30%)
    """
    # 긍정 감정 비율
    positive_ratio = emotion_summary.get('긍정', 0)
    emotion_score = positive_ratio * 100

    # LSM 점수 (0~1 → 0~100)
    lsm_score_100 = lsm_score * 100

    # 가중 평균
    health_score = (
        emotion_score * 0.4 +
        lsm_score_100 * 0.3 +
        balance_score * 0.3
    )

    return min(health_score, 100.0)
```

**작업**:
- [ ] LSM 분석기 구현 (`lsm_analyzer.py`)
- [ ] 턴테이킹 분석기 구현 (`turn_taking_analyzer.py`)
- [ ] 일별 배치 스케줄러 설정
- [ ] 배치 작업 테스트 (수동 실행)

#### 6-7일차: 통합 테스트 및 문서화

**테스트 시나리오**:
1. Flutter 앱에서 텍스트 메시지 전송
   → analysis_results 생성 확인
2. Flutter 앱에서 음성 메시지 전송
   → STT → 감정 분석 확인
3. 일별 배치 수동 실행
   → conversation_analysis 생성 확인

### 📦 Phase 1 결과물

```
ai_backend/app/services/
├── stt_service.py               ✅ STT (Whisper)
├── emotion_analyzer.py          ✅ 멀티모달 감정 분석
├── lsm_analyzer.py              ✅ LSM
├── turn_taking_analyzer.py      ✅ 턴테이킹
├── textrank_extractor.py        ✅ 키워드
└── realtime_listener.py         ✅ Phase 1 파이프라인

ai_backend/app/schedulers/
└── daily_analysis.py             ✅ 일별 배치

Supabase:
├── analysis_results 테이블        ✅
└── conversation_analysis 테이블   ✅
```

### 🎯 Phase 1 성공 기준
- ✅ 텍스트 메시지 감정 분석 정확도 > 85%
- ✅ 음성 STT 정확도 > 90%
- ✅ LSM 점수 계산 정상 동작
- ✅ 일별 배치가 자동 실행되며 에러 없음

---

## MVP Phase 2: 스마트 일정 관리

**목표**: NER 기반 자동 일정 등록
**소요 기간**: 3-4일
**기획서 근거**: 섹션 5 - (2) 스마트 일정 관리

### 🎯 핵심 기능

1. **NER (개체명 인식)**
   - 날짜: "다음 주 토요일", "11월 30일"
   - 시간: "저녁 7시", "오후 3시"
   - 장소: "강남역", "홍대"
   - 활동: "영화", "저녁 식사"

2. **자동 일정 생성**
   - NER 결과 → schedules 테이블 INSERT
   - confirmation_status: 'pending'
   - Flutter 앱에서 확인 요청

3. **한국식 기념일**
   - D+100, D+200, D+1000 계산
   - 음력 생일 지원

### 📅 일정별 구현 계획

#### 1일차: Phase 2 마이그레이션 적용 + NER 서비스

**마이그레이션**:
```sql
-- supabase/migrations/20251119200001_phase2_schedule_tables.sql

-- ner_extractions 테이블
-- anniversaries 테이블
```

**NER 서비스** (`ner_service.py`):
```python
async def extract_entities(text: str) -> List[NERResult]:
    """
    LLM API로 개체명 추출

    Option 1: GPT-4 (정확, 비용 높음)
    Option 2: Gemini (빠름, 비용 낮음)

    추천: Gemini로 시작
    """
    prompt = f"""
다음 대화에서 날짜, 시간, 장소, 활동을 추출하세요.

대화: "{text}"

JSON 형식:
{{
  "entities": [
    {{"type": "DATE", "value": "다음 주 토요일", "normalized": "2025-11-29"}},
    {{"type": "TIME", "value": "7시", "normalized": "19:00"}},
    {{"type": "LOCATION", "value": "강남역"}},
    {{"type": "ACTIVITY", "value": "영화"}}
  ]
}}

추출할 수 없으면 빈 배열 반환.
"""

    response = await gemini_api.generate(prompt)
    entities = parse_ner_response(response)

    return entities
```

#### 2일차: 자동 일정 생성 (`auto_scheduler.py`)

```python
async def create_schedule_from_ner(
    message_id: str,
    couple_id: str,
    ner_results: List[NERResult]
) -> Optional[Schedule]:
    """NER 결과로 일정 생성"""

    # 날짜나 시간이 하나라도 있어야 함
    date_entity = find_entity(ner_results, 'DATE')
    time_entity = find_entity(ner_results, 'TIME')

    if not date_entity and not time_entity:
        return None

    # 일정 정보 구성
    scheduled_at = combine_datetime(
        date_entity.normalized if date_entity else None,
        time_entity.normalized if time_entity else None
    )

    title = find_entity(ner_results, 'ACTIVITY')
    location = find_entity(ner_results, 'LOCATION')

    # 기존 schedules 테이블에 INSERT
    schedule_data = {
        'couple_id': couple_id,
        'source_message_id': message_id,  # 추가 필요한 컬럼
        'title': title.value if title else "자동 생성 일정",
        'location': location.value if location else None,
        'scheduled_at': scheduled_at,
        'is_auto_generated': True,  # 추가 필요한 컬럼
        'confirmation_status': 'pending'  # 추가 필요한 컬럼
    }

    result = await supabase.table('schedules').insert(schedule_data).execute()

    return result.data[0]
```

**작업**:
- [ ] schedules 테이블에 컬럼 추가 필요 여부 확인
  ```sql
  ALTER TABLE schedules ADD COLUMN IF NOT EXISTS source_message_id UUID;
  ALTER TABLE schedules ADD COLUMN IF NOT EXISTS is_auto_generated BOOLEAN DEFAULT FALSE;
  ALTER TABLE schedules ADD COLUMN IF NOT EXISTS confirmation_status VARCHAR(20) DEFAULT 'pending';
  ```

#### 3일차: Realtime Listener에 NER 통합

```python
# realtime_listener.py

async def handle_new_message(self, payload):
    # ... (기존 STT, 감정 분석)

    # ============================================================
    # Phase 2: NER 처리
    # ============================================================
    logger.info(f"Running NER for message {message_id}")
    ner_results = await ner_service.extract(content)

    # ner_extractions 저장
    for entity in ner_results:
        await self.supabase.table('ner_extractions').insert({
            'conversation_id': message_id,
            'entity_type': entity.type,
            'entity_value': entity.value,
            'normalized_value': entity.normalized,
            'confidence': entity.confidence
        }).execute()

    # 자동 일정 생성
    if ner_results:
        schedule = await auto_scheduler.create_schedule_from_ner(
            message_id, couple_id, ner_results
        )

        if schedule:
            logger.info(f"✅ Auto-created schedule: {schedule['title']}")
```

#### 4일차: 통합 테스트

**테스트 시나리오**:
```
메시지: "다음 주 토요일 저녁 7시에 강남역에서 영화 보자"
   ↓
NER 추출:
   - DATE: 2025-11-29
   - TIME: 19:00
   - LOCATION: 강남역
   - ACTIVITY: 영화
   ↓
schedules 테이블 INSERT:
   - title: "영화"
   - location: "강남역"
   - scheduled_at: "2025-11-29 19:00"
   - confirmation_status: "pending"
   ↓
Flutter 앱 Realtime 수신:
   - "일정을 자동으로 생성했어요!" 알림
   - 확인/거절 버튼 표시
```

### 📦 Phase 2 결과물

```
ai_backend/app/services/
├── ner_service.py               ✅ NER (Gemini)
├── auto_scheduler.py            ✅ 자동 일정 생성
└── anniversary_calculator.py    ✅ 기념일 계산

Supabase:
├── ner_extractions 테이블        ✅
├── anniversaries 테이블          ✅
└── schedules 테이블 (컬럼 추가)   ✅
```

### 🎯 Phase 2 성공 기준
- ✅ NER 정확도 > 80%
- ✅ 자동 일정 생성 성공률 > 70%
- ✅ Flutter 앱에서 일정 확인 가능

---

## MVP Phase 3: 관계 깊이 확장

**목표**: LLM 대화 주제 생성 + 활동 추천
**소요 기간**: 5일
**기획서 근거**: 섹션 5 - (4) 관계 깊이 확장 시스템

### 🎯 핵심 기능

1. **주제 분석**
   - 대화 이력 분석 → 부족한 주제 파악
   - 주제별 깊이 점수 계산

2. **LLM 대화 주제 생성**
   - GPT-4로 맞춤형 질문 생성
   - 관계 단계 고려

3. **관계 발전 활동 추천**
   - 대화 패턴 기반 활동 제안
   - 단계별 가이드 제공

### 📅 일정별 구현 계획

#### 1일차: Phase 3 마이그레이션 + 주제 분석

**마이그레이션**:
```sql
-- supabase/migrations/20251119300001_phase3_relationship_tables.sql

-- conversation_topics 테이블
-- topic_history 테이블
-- activities 테이블
-- conversation_summaries 테이블
```

**주제 분석** (`topic_analyzer.py`):
```python
async def analyze_topic_coverage(couple_id: str) -> TopicCoverageReport:
    """
    주제 다양성 분석

    Returns:
        covered_topics: 이미 나눈 주제 (깊이 점수 포함)
        missing_topics: 아직 안 나눈 주제
        low_depth_topics: 얕게만 나눈 주제
    """
    # 최근 30일 메시지 조회
    messages = await fetch_recent_messages(couple_id, days=30)

    # 키워드 기반 주제 분류
    # "미래", "계획" → "미래 계획"
    # "부모", "가족" → "가족"
    topic_distribution = classify_topics(messages)

    # 깊이 점수 계산 (0~1)
    # - 대화 횟수
    # - 대화 길이
    # - 감정 강도
    for topic in topic_distribution:
        topic.depth_score = calculate_depth_score(messages, topic.category)

    # 부족한 주제 파악
    missing_topics = [t for t in ALL_TOPICS if t not in topic_distribution]
    low_depth_topics = [t for t in topic_distribution if t.depth_score < 0.3]

    return TopicCoverageReport(
        covered_topics=topic_distribution,
        missing_topics=missing_topics,
        low_depth_topics=low_depth_topics
    )
```

#### 2-3일차: LLM 주제 생성 + 활동 추천

**(나머지 Phase 3-4는 기존 IMPLEMENTATION_ROADMAP과 동일하므로 생략)**

---

## 📊 전체 일정 요약 (수정)

```
Week 1 (Day 1-5)
├─ Phase 0: 기반 보완 (2-3일)
│   ├─ conversations 테이블 보완
│   ├─ Supabase Storage 설정
│   └─ AI 백엔드 환경 구축
│
└─ Phase 1: 대화 분석 시작 (2-3일)
    ├─ Phase 1 마이그레이션 적용
    └─ Realtime Listener 파이프라인

Week 2 (Day 6-12)
├─ Phase 1: 대화 분석 완료 (3-4일)
│   ├─ STT + 감정 분석
│   └─ 일별 배치 작업
│
└─ Phase 2: 일정 관리 (3-4일)
    ├─ NER 서비스
    └─ 자동 일정 생성

Week 3 (Day 13-19)
└─ Phase 3: 관계 발전 (5-7일)
    ├─ 주제 분석
    ├─ LLM 주제 생성
    └─ 활동 추천

Week 4 (Day 20-25)
└─ Phase 4: 트렌드 & 건강 (5일)
    ├─ 감정 트렌드
    └─ 조기 경고

총 소요: 20-25일 (4-5주)
```

---

## 🎯 최종 목표 (변경 없음)

| 지표 | 목표 | 측정 방법 |
|------|------|----------|
| 사용자 만족도 | **4.5점/5점** | NPS 설문 |
| 일정 등록 자동화율 | **80% 이상** | NER 정확도 |
| 새로운 주제 탐색 | **월 8개 이상** | topic_history |
| 활동 실행률 | **70% 이상** | activities.status |
| 관계 만족도 향상 | **25% 이상** | 분기별 설문 |

---

## 🚀 빠른 시작 가이드

### 1. Phase 0 시작

```bash
# 1. conversations 테이블 스키마 확인
# Supabase Dashboard → Table Editor → conversations

# 2. 부족한 컬럼 추가
# SQL Editor에서 마이그레이션 실행

# 3. Storage Bucket 생성
# Storage → New Bucket → voice-messages

# 4. AI 백엔드 실행
cd ai_backend
source venv/bin/activate
python listener.py
```

### 2. Phase 1 시작

```bash
# 1. Phase 1 마이그레이션 적용
# SQL Editor에서 20251119100001_phase1_analysis_tables.sql 실행

# 2. Realtime Listener 수정
# realtime_listener.py 파이프라인 구현

# 3. 테스트
# Flutter 앱에서 메시지 전송 → analysis_results 확인
```

---

## 📚 관련 문서

- **PLANNING.md**: 원본 기획서 (최종 프로덕션 목표, KoBERT 자체 학습)
- **IMPLEMENTATION_ROADMAP.md** (현재 문서): 프로토타입 구현 계획 (API 기반 빠른 검증)
- **AI_TABLES_SCHEMA.md**: 데이터베이스 스키마 상세 (프로토타입/프로덕션 공통)
- **ARCHITECTURE.md**: 시스템 아키텍처 전체 설계 (작성자 참고용)

---

**마지막 업데이트**: 2025-11-19
**작성자**: GemOphiaLab AI Team
**버전**: 2.0 (프로토타입 - API 기반 하이브리드 아키텍처)

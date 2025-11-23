# 사카린 (GemOphia) 시스템 아키텍처

> AI 기반 종합 관계 관리 플랫폼
> 음성대화와 텍스트 데이터를 활용한 정보 기록, 일정 자동 등록, 대화 주제 제안, 관계 심화 활동 생성

---

## 📋 목차

1. [전체 시스템 아키텍처](#전체-시스템-아키텍처)
2. [데이터베이스 스키마](#데이터베이스-스키마)
3. [AI 서비스 파이프라인](#ai-서비스-파이프라인)
4. [데이터 흐름](#데이터-흐름)
5. [핵심 기능별 구현](#핵심-기능별-구현)
6. [기술 스택](#기술-스택)
7. [보안 및 프라이버시](#보안-및-프라이버시)

---

## 전체 시스템 아키텍처

```
┌─────────────────────────────────────────────────────────────────────┐
│                      Flutter 앱 (사카린)                              │
│                                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐               │
│  │ 음성/텍스트  │  │ 스마트 일정  │  │ 관계 인사이트│               │
│  │ 메시지 입력  │  │ 관리         │  │ 대시보드     │               │
│  └──────────────┘  └──────────────┘  └──────────────┘               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐               │
│  │ 대화 주제    │  │ 관계 발전    │  │ 감정 트렌드  │               │
│  │ 추천 화면    │  │ 활동 제안    │  │ 차트         │               │
│  └──────────────┘  └──────────────┘  └──────────────┘               │
└───┬───────────────────────┬───────────────────┬───────────────────┬─┘
    │                       │                   │                   │
    │ INSERT                │ Realtime 구독      │ SELECT           │
    v                       v                   v                   v
┌─────────────────────────────────────────────────────────────────────┐
│               Supabase (PostgreSQL + Realtime)                      │
│                                                                       │
│  [메시지 & 분석]         [일정 & 기념일]       [관계 발전]           │
│  • messages              • schedules           • conversation_topics│
│  • analysis_results      • anniversaries       • activities         │
│  • conversation_summaries• calendar_events     • topic_history      │
│                                                                       │
│  [감정 & 트렌드]         [선호도 학습]         [관계 건강]           │
│  • emotion_trends        • user_preferences    • relationship_health│
│  • conversation_analysis • ner_extractions     • conflict_alerts    │
│                                                                       │
│  ※ 총 15개 테이블 (아래 상세 스키마 참조)                            │
└───────┬─────────────────────────────────────────────────────────────┘
        │ Realtime 구독 (messages, schedules 등)
        │
        v
┌─────────────────────────────────────────────────────────────────────┐
│              로컬 AI 백엔드 (독립 Python 프로세스)                    │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  listener.py (독립 실행)                                        │ │
│  │  ├─ messages 테이블 구독 → 메시지 분석 파이프라인 트리거         │ │
│  │  ├─ 일별 배치 작업 (23:59) → 대화 요약 & 관계 분석              │ │
│  │  └─ 주간 배치 작업 (일요일) → 감정 트렌드 & 주제 추천           │ │
│  │                                                                  │ │
│  │  ※ FastAPI는 별도 (필요시 API 엔드포인트 제공용)                │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  🎤 음성/텍스트 처리 레이어                                      │ │
│  │  ├─ STT Service (Hugging Face Whisper)                          │ │
│  │  ├─ NER Service (KoBERT) - 날짜, 장소, 활동 추출                │ │
│  │  └─ Auto-Schedule Generator - 일정 자동 생성                    │ │
│  └────────────────────────────────────────────────────────────────┘ │
│         ↓                                                             │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  🧠 감정 분석 레이어                                             │ │
│  │  ├─ Emotion Analyzer (Gemini API)                               │ │
│  │  │   - 7가지 감정 분석 (기쁨, 슬픔, 화남, 불안, 중립, 사랑, 피곤)│ │
│  │  ├─ Multimodal Analyzer (음성 톤 + 텍스트)                      │ │
│  │  └─ Emotion Trend Analyzer (주간/월간 트렌드)                   │ │
│  └────────────────────────────────────────────────────────────────┘ │
│         ↓                                                             │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  💬 대화 분석 레이어                                             │ │
│  │  ├─ LSM Analyzer (Kiwipiepy) - 대화 스타일 유사도               │ │
│  │  ├─ Turn-Taking Analyzer - 대화 균형 분석                       │ │
│  │  ├─ Conversation Summarizer (KoBART) - 대화 요약                │ │
│  │  └─ Keyword Extractor (TextRank) - 핵심 키워드 추출             │ │
│  └────────────────────────────────────────────────────────────────┘ │
│         ↓                                                             │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  🚀 LLM 기반 관계 발전 레이어                                    │ │
│  │  ├─ Topic Generator (GPT-4)                                     │ │
│  │  │   - 대화 이력 분석 → 미탐색 주제 발견                        │ │
│  │  │   - 관계 단계별 맞춤형 질문 생성                             │ │
│  │  ├─ Activity Recommender (GPT-4)                                │ │
│  │  │   - 부족한 대화 영역 파악 → 관계 심화 활동 제안              │ │
│  │  │   - 목적, 준비물, 단계별 가이드 제공                         │ │
│  │  └─ Relationship Coach (GPT-4)                                  │ │
│  │      - 관계 건강도 계산 (감정 40% + LSM 30% + 균형 30%)         │ │
│  │      - 조기 경고 시스템 (부정 감정 누적 감지)                   │ │
│  └────────────────────────────────────────────────────────────────┘ │
│         ↓                                                             │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  📊 분석 결과 저장                                               │ │
│  │  - analysis_results, conversation_analysis, emotion_trends      │ │
│  │  - conversation_topics, activities, relationship_health         │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 데이터베이스 스키마

### 1️⃣ 메시지 & 분석 테이블

```sql
-- ============================================================
-- 메시지 테이블 (원본 데이터)
-- ============================================================
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,
  sender_id UUID NOT NULL,
  content TEXT NOT NULL,
  message_type VARCHAR(20) DEFAULT 'text',  -- 'text', 'voice', 'auto_schedule'
  voice_tone_features JSONB,                -- 음성 톤, 속도 등 (멀티모달 분석용)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_messages_couple_time ON messages(couple_id, created_at DESC);
CREATE INDEX idx_messages_sender ON messages(sender_id, created_at DESC);


-- ============================================================
-- 개체명 추출 결과 (NER)
-- ============================================================
CREATE TABLE ner_extractions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID REFERENCES messages(id) ON DELETE CASCADE,
  entity_type VARCHAR(50),  -- 'DATE', 'LOCATION', 'ACTIVITY', 'PERSON'
  entity_value TEXT,
  confidence DECIMAL(3,2),
  extracted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_ner_message ON ner_extractions(message_id);
CREATE INDEX idx_ner_type ON ner_extractions(entity_type);


-- ============================================================
-- 감정 분석 결과 (메시지별)
-- ============================================================
CREATE TABLE analysis_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID REFERENCES messages(id) ON DELETE CASCADE,
  emotion VARCHAR(50),           -- 주요 감정 ("기쁨", "슬픔" 등)
  confidence DECIMAL(3,2),       -- 확신도 (0.00 ~ 1.00)
  all_scores JSONB,              -- {"기쁨": 0.89, "슬픔": 0.02, ...}
  voice_emotion JSONB,           -- 음성 기반 감정 (멀티모달)
  topics TEXT[],                 -- 대화 주제 태그
  keywords TEXT[],               -- TextRank로 추출한 키워드
  processed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_analysis_message ON analysis_results(message_id);
CREATE INDEX idx_analysis_emotion ON analysis_results(emotion, processed_at DESC);


-- ============================================================
-- 대화 요약 (일별)
-- ============================================================
CREATE TABLE conversation_summaries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,
  summary_date DATE NOT NULL,
  summary_text TEXT,                    -- KoBART로 생성한 요약
  key_moments TEXT[],                   -- 하이라이트 문장들
  total_messages INT,
  total_words INT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(couple_id, summary_date)
);

CREATE INDEX idx_summaries_couple_date ON conversation_summaries(couple_id, summary_date DESC);


-- ============================================================
-- 대화 분석 (일별 종합)
-- ============================================================
CREATE TABLE conversation_analysis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,
  analysis_date DATE NOT NULL,

  -- 감정 요약
  emotion_summary JSONB,         -- {"긍정": 0.65, "중립": 0.25, "부정": 0.10}
  dominant_emotion VARCHAR(50),  -- 가장 많이 나타난 감정

  -- LSM 분석
  lsm_score DECIMAL(3,2),        -- Language Style Matching (0.00 ~ 1.00)
  lsm_details JSONB,             -- 카테고리별 상세 점수

  -- 턴테이킹 분석
  turn_taking JSONB,             -- {"balance_score": 95.0, "turn_ratio": 0.475, ...}

  -- 관계 건강도
  relationship_health DECIMAL(5,2),  -- 0 ~ 100

  -- 갈등 감지
  conflict_detected BOOLEAN DEFAULT FALSE,
  conflict_intensity DECIMAL(3,2),

  -- 키워드
  keywords TEXT[],

  analyzed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(couple_id, analysis_date)
);

CREATE INDEX idx_conversation_couple_date ON conversation_analysis(couple_id, analysis_date DESC);


-- ============================================================
-- 감정 트렌드 (주간/월간 집계)
-- ============================================================
CREATE TABLE emotion_trends (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,
  period_type VARCHAR(20),       -- 'weekly', 'monthly'
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,

  emotion_distribution JSONB,    -- 7가지 감정별 비율
  trend_direction VARCHAR(20),   -- 'improving', 'stable', 'declining'
  positive_ratio_change DECIMAL(5,2),  -- 긍정 감정 변화율 (%)

  analyzed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(couple_id, period_type, period_start)
);

CREATE INDEX idx_trends_couple ON emotion_trends(couple_id, period_start DESC);
```

### 2️⃣ 일정 & 기념일 테이블

```sql
-- ============================================================
-- 자동 생성 일정
-- ============================================================
CREATE TABLE schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,
  created_by UUID,               -- 일정을 만든 사람 (NULL이면 AI 자동 생성)
  source_message_id UUID REFERENCES messages(id),  -- 출처 메시지

  title VARCHAR(200),
  description TEXT,
  location VARCHAR(200),
  scheduled_at TIMESTAMP WITH TIME ZONE,
  duration_minutes INT,

  is_auto_generated BOOLEAN DEFAULT FALSE,
  confirmation_status VARCHAR(20) DEFAULT 'pending',  -- 'pending', 'confirmed', 'rejected'

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_schedules_couple ON schedules(couple_id, scheduled_at);
CREATE INDEX idx_schedules_status ON schedules(confirmation_status);


-- ============================================================
-- 기념일 관리
-- ============================================================
CREATE TABLE anniversaries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,
  anniversary_type VARCHAR(50),  -- 'first_day', '100days', '200days', '1year', 'birthday', 'custom'
  title VARCHAR(200),
  base_date DATE NOT NULL,       -- 기준일 (연애 시작일, 생일 등)
  is_lunar BOOLEAN DEFAULT FALSE,-- 음력 여부
  day_count INT,                 -- D+100, D+200 등
  recurrence VARCHAR(20),        -- 'once', 'yearly', 'monthly'

  reminder_days INT[] DEFAULT ARRAY[7, 3, 1],  -- 며칠 전에 알림

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_anniversaries_couple ON anniversaries(couple_id, base_date);


-- ============================================================
-- 캘린더 이벤트 (계절별 추천 등)
-- ============================================================
CREATE TABLE calendar_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID,                -- NULL이면 전체 커플 대상
  event_type VARCHAR(50),        -- 'season', 'holiday', 'recommendation'
  title VARCHAR(200),
  description TEXT,
  suggested_date DATE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_calendar_couple ON calendar_events(couple_id, suggested_date);
```

### 3️⃣ 관계 발전 테이블

```sql
-- ============================================================
-- 대화 주제 추천 (LLM 생성)
-- ============================================================
CREATE TABLE conversation_topics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,

  topic_category VARCHAR(100),   -- '미래 계획', '가족', '가치관', '추억' 등
  topic_title VARCHAR(200),
  core_question TEXT,            -- 핵심 질문
  context_explanation TEXT,      -- 왜 지금 이 주제가 중요한지
  guide_questions TEXT[],        -- 세부 가이드 질문 3-5개

  conversation_depth_level INT,  -- 1~5 (얼마나 깊은 대화인지)
  estimated_time_minutes INT,    -- 예상 소요 시간

  generated_by VARCHAR(50) DEFAULT 'gpt-4',
  status VARCHAR(20) DEFAULT 'suggested',  -- 'suggested', 'in_progress', 'completed', 'skipped'

  suggested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_topics_couple ON conversation_topics(couple_id, suggested_at DESC);
CREATE INDEX idx_topics_status ON conversation_topics(status);


-- ============================================================
-- 주제 탐색 기록
-- ============================================================
CREATE TABLE topic_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,
  topic_category VARCHAR(100),
  last_discussed_at TIMESTAMP WITH TIME ZONE,
  discussion_count INT DEFAULT 0,
  depth_score DECIMAL(3,2),      -- 얼마나 깊이 대화했는지 (0 ~ 1)

  UNIQUE(couple_id, topic_category)
);

CREATE INDEX idx_topic_history_couple ON topic_history(couple_id, last_discussed_at DESC);


-- ============================================================
-- 관계 발전 활동 추천
-- ============================================================
CREATE TABLE activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,

  activity_title VARCHAR(200),
  activity_purpose TEXT,         -- 이 활동의 목적 (예: "서로의 가치관 이해")
  category VARCHAR(100),         -- '대화 촉진', '추억 만들기', '감정 표현' 등

  preparation_items TEXT[],      -- 준비물
  step_by_step_guide JSONB,      -- 단계별 진행 방법
  expected_outcome TEXT,         -- 기대 효과

  difficulty_level INT,          -- 1~5
  estimated_time_minutes INT,

  generated_by VARCHAR(50) DEFAULT 'gpt-4',
  status VARCHAR(20) DEFAULT 'suggested',  -- 'suggested', 'in_progress', 'completed', 'skipped'

  suggested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  feedback_rating INT,           -- 1~5 (실행 후 사용자 평가)
  feedback_text TEXT
);

CREATE INDEX idx_activities_couple ON activities(couple_id, suggested_at DESC);
CREATE INDEX idx_activities_status ON activities(status);
```

### 4️⃣ 관계 건강 & 학습 테이블

```sql
-- ============================================================
-- 관계 건강도 점수 (일별 추적)
-- ============================================================
CREATE TABLE relationship_health (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,
  health_date DATE NOT NULL,

  total_score DECIMAL(5,2),      -- 0 ~ 100
  emotion_score DECIMAL(5,2),    -- 감정 점수 (40% 가중치)
  lsm_score DECIMAL(5,2),        -- LSM 점수 (30% 가중치)
  balance_score DECIMAL(5,2),    -- 턴테이킹 균형 (30% 가중치)

  trend VARCHAR(20),             -- 'improving', 'stable', 'declining'

  calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(couple_id, health_date)
);

CREATE INDEX idx_health_couple ON relationship_health(couple_id, health_date DESC);


-- ============================================================
-- 갈등 조기 경고
-- ============================================================
CREATE TABLE conflict_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,

  alert_type VARCHAR(50),        -- 'negative_trend', 'reduced_communication', 'shallow_conversations'
  severity VARCHAR(20),          -- 'low', 'medium', 'high'
  description TEXT,
  recommended_actions JSONB,     -- 추천 활동들

  detected_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  resolved_at TIMESTAMP WITH TIME ZONE,
  is_resolved BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_alerts_couple ON conflict_alerts(couple_id, detected_at DESC);
CREATE INDEX idx_alerts_unresolved ON conflict_alerts(is_resolved, detected_at DESC);


-- ============================================================
-- 사용자 선호도 학습
-- ============================================================
CREATE TABLE user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,

  preference_type VARCHAR(50),   -- 'food', 'movie_genre', 'activity', 'music', 'travel'
  preference_value TEXT,
  confidence DECIMAL(3,2),       -- 학습 확신도

  learned_from_message_id UUID REFERENCES messages(id),
  learned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(user_id, preference_type, preference_value)
);

CREATE INDEX idx_preferences_user ON user_preferences(user_id, preference_type);
```

---

## AI 서비스 파이프라인

### 📌 파이프라인 1: 실시간 메시지 분석

```
새 메시지 INSERT
    ↓
Realtime Listener 감지
    ↓
┌─────────────────────────────┐
│ 1. STT (음성일 경우)         │
│    - Hugging Face Whisper   │
│    - 음성 톤 추출           │
└─────────────────────────────┘
    ↓
┌─────────────────────────────┐
│ 2. NER (개체명 인식)         │
│    - KoBERT                 │
│    - 날짜, 장소, 활동 추출   │
│    → ner_extractions 저장   │
└─────────────────────────────┘
    ↓
┌─────────────────────────────┐
│ 3. 일정 자동 생성 (필요시)   │
│    - NER 결과 분석          │
│    → schedules 저장         │
│    - confirmation_status:   │
│      'pending'              │
└─────────────────────────────┘
    ↓
┌─────────────────────────────┐
│ 4. 감정 분석 (Multimodal)   │
│    - 텍스트: Gemini API     │
│    - 음성: 톤 분석          │
│    → analysis_results 저장  │
└─────────────────────────────┘
    ↓
Flutter 앱 Realtime 수신
```

### 📌 파이프라인 2: 일별 대화 종합 분석 (23:59 실행)

```
스케줄러 트리거
    ↓
┌─────────────────────────────┐
│ 1. 오늘의 메시지 조회        │
│    - couple_id별 그룹핑     │
└─────────────────────────────┘
    ↓
┌─────────────────────────────┐
│ 2. 대화 요약 생성            │
│    - KoBART                 │
│    → conversation_summaries │
└─────────────────────────────┘
    ↓
┌─────────────────────────────┐
│ 3. LSM 분석                 │
│    - Kiwipiepy 형태소 분석  │
│    - 대화 스타일 유사도     │
└─────────────────────────────┘
    ↓
┌─────────────────────────────┐
│ 4. 턴테이킹 분석             │
│    - 대화 균형 점수         │
│    - 응답 시간 분석         │
└─────────────────────────────┘
    ↓
┌─────────────────────────────┐
│ 5. 관계 건강도 계산          │
│    - 감정(40%) + LSM(30%)   │
│      + 균형(30%)            │
│    → conversation_analysis  │
│    → relationship_health    │
└─────────────────────────────┘
    ↓
┌─────────────────────────────┐
│ 6. 갈등 조기 경고 체크       │
│    - 부정 감정 누적 감지    │
│    - 대화 감소 패턴 감지    │
│    → conflict_alerts        │
└─────────────────────────────┘
```

### 📌 파이프라인 3: 주간 관계 발전 제안 (일요일 실행)

```
스케줄러 트리거
    ↓
┌─────────────────────────────┐
│ 1. 주간 감정 트렌드 분석     │
│    → emotion_trends         │
└─────────────────────────────┘
    ↓
┌─────────────────────────────┐
│ 2. 대화 패턴 분석            │
│    - topic_history 업데이트 │
│    - 부족한 주제 영역 파악  │
└─────────────────────────────┘
    ↓
┌─────────────────────────────┐
│ 3. LLM 대화 주제 생성        │
│    - GPT-4 API              │
│    - 관계 단계 고려         │
│    - 미탐색 주제 제안       │
│    → conversation_topics    │
└─────────────────────────────┘
    ↓
┌─────────────────────────────┐
│ 4. 관계 발전 활동 추천       │
│    - GPT-4 API              │
│    - 맞춤형 활동 생성       │
│    → activities             │
└─────────────────────────────┘
    ↓
Flutter 앱 알림 전송
```

---

## 데이터 흐름

### 시나리오 1: 음성 메시지로 일정 잡기

```
사용자 A: "다음 주 토요일 7시에 강남역에서 영화 보자"
    ↓
Flutter: 음성 녹음 → messages 테이블 INSERT
    (message_type: 'voice', voice_tone_features: {...})
    ↓
AI 백엔드 Realtime Listener 감지
    ↓
STT Service: "다음 주 토요일 7시에 강남역에서 영화 보자"
    ↓
NER Service:
    - DATE: "다음 주 토요일" → 2025-01-25
    - TIME: "7시" → 19:00
    - LOCATION: "강남역"
    - ACTIVITY: "영화"
    ↓
Auto-Schedule Generator:
    schedules 테이블에 INSERT
    {
      title: "영화 보기",
      location: "강남역",
      scheduled_at: "2025-01-25 19:00",
      is_auto_generated: true,
      confirmation_status: 'pending'
    }
    ↓
Flutter 앱: Realtime으로 일정 제안 수신
    → 사용자에게 확인 요청 UI 표시
```

### 시나리오 2: 감정 트렌드 하락 감지 → 조기 경고

```
일별 배치 분석 (월~일 7일간)
    ↓
Trend Analyzer:
    - 월: 긍정 70%, 부정 10%
    - 화: 긍정 65%, 부정 15%
    - 수: 긍정 60%, 부정 20%
    - 목: 긍정 55%, 부정 25%
    - 금: 긍정 50%, 부정 30%  ← 부정 30% 초과!
    ↓
Conflict Alert 생성:
    conflict_alerts 테이블 INSERT
    {
      alert_type: 'negative_trend',
      severity: 'medium',
      description: '최근 5일간 부정적인 감정이 증가하고 있습니다',
      recommended_actions: [
        '대화 주제: "우리에게 지금 필요한 것은?"',
        '활동: "함께 산책하며 가벼운 이야기 나누기"'
      ]
    }
    ↓
Flutter 앱: 푸시 알림 전송
```

### 시나리오 3: 대화 주제 제안

```
주간 배치 분석 (일요일)
    ↓
Topic Analyzer:
    topic_history 분석 결과:
    - '취미': 10회 (depth: 0.8)  ✅ 충분
    - '일상': 15회 (depth: 0.6)  ✅
    - '미래 계획': 2회 (depth: 0.3)  ❌ 부족!
    - '가족': 0회  ❌ 없음!
    ↓
GPT-4 Topic Generator:
    Input: {
      couple_history: "연애 6개월",
      discussed_topics: ['취미', '일상'],
      missing_topics: ['미래 계획', '가족'],
      recent_emotion: '긍정 60%',
      relationship_stage: 'early'
    }
    ↓
    Output: {
      topic_title: "우리의 10년 후",
      core_question: "10년 후 우리는 어떤 모습일까요?",
      context: "관계 초기에 서로의 미래 비전을 공유하면...",
      guide_questions: [
        "10년 후 어떤 일을 하고 있을까요?",
        "어디에서 살고 싶나요?",
        "가장 이루고 싶은 것은?"
      ],
      depth_level: 4,
      estimated_time: 30
    }
    ↓
conversation_topics 테이블 INSERT
    ↓
Flutter 앱: "새로운 대화 주제가 도착했어요!" 알림
```

---

## 핵심 기능별 구현

### 1. 정보 관리 시스템

**기술 스택:**
- STT: Hugging Face Whisper (오픈소스)
- NER: KoBERT fine-tuned
- Keyword Extraction: LLM API

**구현 파일:**
```
ai_backend/app/services/
├── stt_service.py              # 음성 → 텍스트
├── ner_service.py              # 개체명 인식
├── auto_scheduler.py           # 일정 자동 생성
└── keyword_extractor.py        # 키워드 추출
```

### 2. 스마트 일정 관리

**기능:**
- 자동 일정 인식 및 등록
- 한국식 기념일 계산 (100일, 200일, 1000일)
- 음력 생일 지원
- 계절별 이벤트 추천

**구현 파일:**
```
ai_backend/app/services/
├── anniversary_calculator.py   # 기념일 계산
├── lunar_calendar.py           # 음력 변환
└── seasonal_recommender.py     # 계절 추천
```

### 3. 대화 분석 엔진

**멀티모달 감정 분석:**
- 텍스트: KoBERT (F1-score 0.87 목표)
- 음성: 톤, 속도 분석
- 융합: 가중 평균 (텍스트 70% + 음성 30%)

**대화 요약:**
- KoBART (추상적 요약)
- TextRank (핵심 문장 추출)

**구현 파일:**
```
ai_backend/app/services/
├── emotion_analyzer.py         # (기존)
├── multimodal_analyzer.py      # 멀티모달 융합
├── conversation_summarizer.py  # KoBART 요약
└── textrank_extractor.py       # 핵심 문장
```

### 4. 관계 깊이 확장 시스템

**LLM 프롬프트 구조:**
```python
TOPIC_GENERATION_PROMPT = """
당신은 커플 관계 전문 상담사입니다.

커플 정보:
- 관계 기간: {relationship_duration}
- 최근 대화 주제: {recent_topics}
- 아직 나누지 않은 주제: {missing_topics}
- 최근 감정 상태: {emotion_summary}
- 관계 단계: {relationship_stage}

위 정보를 바탕으로 이 커플에게 지금 가장 필요한 대화 주제를 제안하세요.

다음 JSON 형식으로 응답하세요:
{
  "topic_title": "주제 제목",
  "topic_category": "카테고리 (미래 계획, 가족, 가치관 등)",
  "core_question": "핵심 질문",
  "context_explanation": "왜 지금 이 주제가 중요한지",
  "guide_questions": ["질문1", "질문2", "질문3"],
  "conversation_depth_level": 1~5,
  "estimated_time_minutes": 예상 시간
}
"""
```

**구현 파일:**
```
ai_backend/app/services/
├── topic_generator.py          # GPT-4 주제 생성
├── activity_recommender.py     # GPT-4 활동 추천
└── relationship_coach.py       # 종합 코칭
```

### 5. 예방적 관계 케어

**조기 경고 조건:**
1. 부정 감정 30% 초과 (3일 연속)
2. 일일 대화량 50% 감소 (1주일 평균 대비)
3. 대화 깊이 0.3 이하 (1주일 평균)
4. LSM 점수 0.4 이하

**구현 파일:**
```
ai_backend/app/services/
├── trend_analyzer.py           # 트렌드 분석
├── conflict_detector.py        # 갈등 감지
└── early_warning.py            # 조기 경고
```

---

## 기술 스택

### Frontend (Flutter)
```yaml
dependencies:
  get: ^4.7.2                    # 상태관리
  supabase_flutter: ^2.9.1       # Supabase 클라이언트
  flutter_dotenv: ^5.2.1         # 환경변수

  # UI
  google_fonts: ^6.2.1
  flutter_screenutil: ^5.9.3
  fl_chart: ^0.69.0              # 감정 트렌드 차트
  table_calendar: ^3.1.3         # 캘린더

  # 음성
  record: ^5.0.0                 # 음성 녹음
  audioplayers: ^5.2.0           # 음성 재생
```

### Backend (AI)
```txt
# Web Framework
fastapi==0.115.0
uvicorn[standard]==0.32.0

# Database
supabase==2.9.1

# AI APIs
google-generativeai==0.8.3      # Gemini
openai==1.54.0                  # GPT-4

# NLP - Korean
kiwipiepy==0.18.0               # 형태소 분석
transformers==4.40.0            # KoBERT, KoBART
sentence-transformers==3.2.0    # Embeddings

# STT
openai-whisper==20231117        # Whisper (로컬)
# 또는 Hugging Face transformers

# Utils
python-dotenv==1.0.1
redis==5.2.0                    # 캐싱
apscheduler==3.10.4             # 스케줄러
```

### Infrastructure
- **Database**: Supabase (PostgreSQL 15)
- **Realtime**: Supabase Realtime (WebSocket)
- **Cache**: Redis (선택사항)
- **Scheduler**: APScheduler (배치 작업)

---

## 보안 및 프라이버시

### Row Level Security (RLS)

```sql
-- messages 테이블
CREATE POLICY "Users can view their couple's messages"
  ON messages FOR SELECT
  USING (
    couple_id IN (
      SELECT couple_id FROM user_couples
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert to their couple's messages"
  ON messages FOR INSERT
  WITH CHECK (
    sender_id = auth.uid() AND
    couple_id IN (
      SELECT couple_id FROM user_couples
      WHERE user_id = auth.uid()
    )
  );

-- 다른 테이블도 유사하게 couple_id 기반 RLS 적용
```

### 데이터 보안 아키텍처

```
┌─────────────────────────────────────────┐
│  Flutter 앱 (사용자 디바이스)            │
│  ├─ 로컬 음성 전처리                    │
│  ├─ End-to-End 암호화                   │
│  └─ 최소 권한 원칙 (Anon Key)           │
└────────────┬────────────────────────────┘
             │ HTTPS + SSL
             v
┌─────────────────────────────────────────┐
│  Supabase                               │
│  ├─ Row Level Security (RLS)            │
│  ├─ 데이터 암호화 (at rest)             │
│  └─ 백업 및 복구                        │
└────────────┬────────────────────────────┘
             │ Service Role Key (서버만)
             v
┌─────────────────────────────────────────┐
│  AI 백엔드                              │
│  ├─ 연합학습 (Federated Learning)       │
│  ├─ 차분 프라이버시 (Differential)      │
│  └─ 동형 암호화 (선택사항)              │
└─────────────────────────────────────────┘
```

### 프라이버시 보호 기술

1. **연합학습 (Federated Learning)**
   - 원본 데이터는 서버로 전송 안 함
   - 각 디바이스에서 모델 학습
   - 학습된 파라미터만 공유

2. **차분 프라이버시 (Differential Privacy)**
   - 데이터에 수학적 노이즈 추가
   - 개인 식별 불가능하게 처리

3. **데이터 보관 기간**
   - 메시지: 1년 (이후 자동 삭제 옵션)
   - 분석 결과: 2년
   - 음성 원본: 즉시 삭제 (텍스트 변환 후)

---

## 정량적 성과 목표

| 지표 | 목표 | 측정 방법 |
|------|------|----------|
| 사용자 만족도 | 4.5점/5점 | NPS 설문 |
| 일정 등록 자동화율 | 80% 이상 | NER 정확도 |
| 새로운 주제 탐색 | 월 8개 이상 | topic_history 분석 |
| 활동 실행률 | 70% 이상 | activities.status='completed' |
| 관계 만족도 향상 | 25% 이상 | 분기별 설문 (전후 비교) |

---

## 향후 개선 사항

- [ ] **KoBERT 자체 학습** - Gemini API 비용 절감
- [ ] **음성 톤 분석 고도화** - 감정 인식 정확도 향상
- [ ] **주제 임베딩** - Sentence Transformers로 유사 주제 군집화
- [ ] **갈등 예측 모델** - LSTM 기반 시계열 예측
- [ ] **다국어 지원** - 영어, 일본어 확장
- [ ] **커플 페르소나 분석** - MBTI 연동, 성격 기반 추천

---

## 개발 환경 설정

### AI 백엔드 (Realtime Listener)
```bash
cd ai_backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# .env 설정
cp .env.example .env
# SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, GEMINI_API_KEY, OPENAI_API_KEY 입력

# Realtime Listener 실행 (메인)
python listener.py

# (선택사항) FastAPI 서버 실행 (API 필요시)
# python -m app.main
```

### Flutter 앱
```bash
cd gemophia_app
flutter pub get

# .env 설정
cp .env.example .env
# SUPABASE_URL, SUPABASE_ANON_KEY 입력

# 앱 실행
flutter run
```

---

## 참고 문서

- [기획서](./2025년_새싹_해커톤(AI서비스기획서).pdf)
- [Supabase Realtime](https://supabase.com/docs/guides/realtime)
- [FastAPI](https://fastapi.tiangolo.com/)
- [KoBERT](https://github.com/SKTBrain/KoBERT)
- [Google Gemini API](https://ai.google.dev/docs)
- [GPT-4 API](https://platform.openai.com/docs/models/gpt-4)

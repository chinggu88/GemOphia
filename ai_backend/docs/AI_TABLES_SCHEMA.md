# AI 전용 테이블 스키마 설계

> **기존 테이블 유지 + AI 분석 테이블 추가**
> 기획서 기반 단계별 구현

---

## 📋 목차

1. [설계 원칙](#설계-원칙)
2. [기존 테이블 (참조용)](#기존-테이블-참조용)
3. [Phase 0: conversations 테이블 보완](#phase-0-conversations-테이블-보완)
4. [Phase 1: 대화 분석 테이블](#phase-1-대화-분석-테이블)
5. [Phase 2: 일정 관리 테이블](#phase-2-일정-관리-테이블)
6. [Phase 3: 관계 발전 테이블](#phase-3-관계-발전-테이블)
7. [Phase 4: 트렌드 & 건강 테이블](#phase-4-트렌드--건강-테이블)
8. [테이블 관계도](#테이블-관계도)

---

## 설계 원칙

### ✅ DO (해야 할 것)
1. **독립적인 AI 분석 테이블 생성**
   - 기존 테이블 로직 수정 금지
   - 외래키로만 연결
   - AI 서비스 전용

2. **기존 테이블 참조**
   - `conversations.id` → AI 분석 결과 연결
   - `couples.id` → 커플별 분석 데이터
   - `profiles.id` → 사용자별 선호도

3. **Phase별 점진적 추가**
   - Phase 0: conversations 테이블 최소 보완 (AI 기능을 위한 컬럼만)
   - Phase 1: 감정 분석
   - Phase 2: NER + 일정
   - Phase 3: LLM 주제 생성
   - Phase 4: 트렌드 분석

### ❌ DON'T (하지 말아야 할 것)
1. 기존 Flutter 앱 로직 변경 금지
2. 기존 데이터 마이그레이션 금지
3. 기존 테이블의 핵심 구조 변경 금지

### ⚠️ 예외: Phase 0 최소 보완
- **conversations 테이블에만** AI 기능을 위한 최소한의 컬럼 추가 허용
- Flutter 앱은 이 컬럼들을 선택적으로 사용 (기존 기능에 영향 없음)

---

## 기존 테이블 (참조용)

### 현재 존재하는 5개 테이블

```sql
-- ============================================================
-- 1. conversations (대화 메시지)
-- ============================================================
-- Phase 0에서 보완 예정 (AI 기능을 위한 컬럼 추가)
CREATE TABLE conversations (
  id UUID PRIMARY KEY,
  couple_id UUID NOT NULL,  -- couples.id 참조
  user_id UUID,             -- 발신자
  content TEXT,             -- 메시지 내용 (음성인 경우 STT 후 업데이트)
  conversation_type VARCHAR,

  -- Phase 0에서 추가할 AI 전용 컬럼들:
  message_type VARCHAR(20) DEFAULT 'text',  -- 'text' or 'voice'
  audio_url TEXT,                           -- Supabase Storage URL (음성 메시지)
  voice_tone_features JSONB,                -- 음성 톤 분석 결과
  sentiment VARCHAR(50),                    -- AI가 업데이트 (기쁨, 슬픔 등)
  emotion_score INT,                        -- AI 감정 점수 (0-100)

  created_at TIMESTAMP WITH TIME ZONE
);

-- ============================================================
-- 2. couples (커플 정보)
-- ============================================================
CREATE TABLE couples (
  id UUID PRIMARY KEY,
  user1_id UUID NOT NULL,   -- 사용자 A
  user2_id UUID,            -- 사용자 B (선택적?)
  created_at TIMESTAMP WITH TIME ZONE
);

-- ============================================================
-- 3. profiles (사용자 프로필)
-- ============================================================
CREATE TABLE profiles (
  id UUID PRIMARY KEY,
  -- 기타 프로필 정보
  created_at TIMESTAMP WITH TIME ZONE
);

-- ============================================================
-- 4. schedules (일정)
-- ============================================================
CREATE TABLE schedules (
  id UUID PRIMARY KEY,
  couple_id UUID NOT NULL,
  -- 일정 정보
  created_at TIMESTAMP WITH TIME ZONE
);

-- ============================================================
-- 5. todos (할일)
-- ============================================================
CREATE TABLE todos (
  id UUID PRIMARY KEY,
  couple_id UUID NOT NULL,
  -- 할일 정보
  created_at TIMESTAMP WITH TIME ZONE
);
```

---

## Phase 0: conversations 테이블 보완

### 목표
- 기존 conversations 테이블에 AI 기능을 위한 최소한의 컬럼 추가
- 텍스트 + 음성 메시지 지원
- AI 분석 결과 저장 필드 추가

### 추가할 컬럼

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

-- 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_conversations_message_type
  ON conversations(message_type);

CREATE INDEX IF NOT EXISTS idx_conversations_sentiment
  ON conversations(sentiment, created_at DESC);

-- 코멘트
COMMENT ON COLUMN conversations.message_type IS 'text 또는 voice';
COMMENT ON COLUMN conversations.audio_url IS 'Supabase Storage 음성 파일 URL (voice-messages bucket)';
COMMENT ON COLUMN conversations.voice_tone_features IS '음성 톤 분석 결과 JSON (선택적)';
COMMENT ON COLUMN conversations.sentiment IS 'AI 감정 분석 결과 (기쁨, 슬픔, 화남, 불안, 중립, 사랑, 피곤)';
COMMENT ON COLUMN conversations.emotion_score IS 'AI 감정 점수 (0-100)';
```

### 컬럼 설명

| 컬럼명 | 타입 | 설명 | 사용 시점 |
|--------|------|------|----------|
| `message_type` | VARCHAR(20) | 'text' or 'voice' | Flutter 앱에서 INSERT 시 |
| `audio_url` | TEXT | Supabase Storage URL | Flutter 앱 (음성 업로드 후) |
| `voice_tone_features` | JSONB | 음성 톤, 속도 등 | AI 백엔드 (STT 후) |
| `sentiment` | VARCHAR(50) | 감정 분석 결과 | AI 백엔드 (분석 후) |
| `emotion_score` | INT | 감정 점수 0-100 | AI 백엔드 (분석 후) |

### 기존 앱 영향도

✅ **영향 없음**:
- 모든 컬럼이 선택적 (NULL 허용 or DEFAULT 값)
- 기존 Flutter 앱 코드 수정 불필요
- 기존 메시지는 자동으로 message_type='text'

⚠️ **Phase 0 이후 Flutter 앱 수정 권장**:
- 음성 메시지 기능 추가 시 message_type, audio_url 활용
- AI 분석 결과 UI 표시 시 sentiment, emotion_score 활용

---

## Phase 1: 대화 분석 테이블

### 목표
- 감정 분석 결과 저장
- 일별 대화 종합 분석
- LSM + 턴테이킹 점수

### 테이블 구조

```sql
-- ============================================================
-- 1.1 analysis_results (메시지별 감정 분석)
-- ============================================================
CREATE TABLE analysis_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL,  -- ✅ 기존 conversations.id 참조

  -- 감정 분석 결과
  emotion VARCHAR(50) NOT NULL,   -- '기쁨', '슬픔', '화남', '불안', '중립', '사랑', '피곤'
  confidence DECIMAL(3,2),        -- 0.00 ~ 1.00
  all_scores JSONB,               -- {"기쁨": 0.89, "슬픔": 0.02, ...}

  -- 멀티모달 분석 (Phase 1.5)
  voice_emotion JSONB,            -- 음성 톤 기반 감정

  -- 키워드 & 주제 (Phase 1)
  keywords TEXT[] DEFAULT '{}',   -- TextRank 추출
  topics TEXT[] DEFAULT '{}',     -- 대화 주제 태그

  processed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- 외래키
  CONSTRAINT fk_conversation
    FOREIGN KEY (conversation_id)
    REFERENCES conversations(id)
    ON DELETE CASCADE
);

CREATE INDEX idx_analysis_conversation ON analysis_results(conversation_id);
CREATE INDEX idx_analysis_emotion ON analysis_results(emotion, processed_at DESC);

COMMENT ON TABLE analysis_results IS 'AI 감정 분석 결과 (메시지별)';
COMMENT ON COLUMN analysis_results.all_scores IS '7가지 감정 점수 (JSON)';


-- ============================================================
-- 1.2 conversation_analysis (일별 대화 종합 분석)
-- ============================================================
CREATE TABLE conversation_analysis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,        -- ✅ 기존 couples.id 참조
  analysis_date DATE NOT NULL,

  -- 감정 요약
  emotion_summary JSONB,          -- {"긍정": 0.65, "중립": 0.25, "부정": 0.10}
  dominant_emotion VARCHAR(50),   -- 가장 많이 나타난 감정

  -- LSM 분석
  lsm_score DECIMAL(3,2),         -- Language Style Matching (0.00 ~ 1.00)
  lsm_details JSONB,              -- 카테고리별 상세 점수

  -- 턴테이킹 분석
  turn_taking JSONB,              -- {"balance_score": 95.0, "turn_ratio": 0.475}

  -- 관계 건강도
  relationship_health DECIMAL(5,2), -- 0 ~ 100

  -- 갈등 감지
  conflict_detected BOOLEAN DEFAULT FALSE,
  conflict_intensity DECIMAL(3,2),

  -- 키워드
  keywords TEXT[] DEFAULT '{}',

  analyzed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- 외래키
  CONSTRAINT fk_couple
    FOREIGN KEY (couple_id)
    REFERENCES couples(id)
    ON DELETE CASCADE,

  -- 유니크 제약
  UNIQUE(couple_id, analysis_date)
);

CREATE INDEX idx_conv_analysis_couple ON conversation_analysis(couple_id, analysis_date DESC);

COMMENT ON TABLE conversation_analysis IS '일별 대화 종합 분석 (LSM + 턴테이킹 + 감정)';
```

---

## Phase 2: 일정 관리 테이블

### 목표
- NER 결과 저장
- 한국식 기념일 관리

### 테이블 구조

```sql
-- ============================================================
-- 2.1 ner_extractions (개체명 인식 결과)
-- ============================================================
CREATE TABLE ner_extractions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL,  -- ✅ conversations.id 참조

  entity_type VARCHAR(50) NOT NULL,  -- 'DATE', 'TIME', 'LOCATION', 'ACTIVITY'
  entity_value TEXT NOT NULL,        -- "다음 주 토요일"
  normalized_value TEXT,             -- "2025-11-22"
  confidence DECIMAL(3,2),           -- 0.00 ~ 1.00

  extracted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- 외래키
  CONSTRAINT fk_ner_conversation
    FOREIGN KEY (conversation_id)
    REFERENCES conversations(id)
    ON DELETE CASCADE
);

CREATE INDEX idx_ner_conversation ON ner_extractions(conversation_id);
CREATE INDEX idx_ner_type ON ner_extractions(entity_type);

COMMENT ON TABLE ner_extractions IS 'NER 개체명 인식 결과 (날짜, 시간, 장소, 활동)';


-- ============================================================
-- 2.2 anniversaries (한국식 기념일)
-- ============================================================
CREATE TABLE anniversaries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,        -- ✅ couples.id 참조

  anniversary_type VARCHAR(50),   -- '100days', '200days', '1000days', 'birthday', 'custom'
  title VARCHAR(200) NOT NULL,    -- "사귄 지 100일"
  base_date DATE NOT NULL,        -- 기준일 (연애 시작일, 생일 등)

  is_lunar BOOLEAN DEFAULT FALSE, -- 음력 여부
  day_count INT,                  -- D+100, D+200 등
  recurrence VARCHAR(20),         -- 'once', 'yearly', 'monthly'

  reminder_days INT[] DEFAULT ARRAY[7, 3, 1], -- 며칠 전에 알림

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- 외래키
  CONSTRAINT fk_anniversary_couple
    FOREIGN KEY (couple_id)
    REFERENCES couples(id)
    ON DELETE CASCADE
);

CREATE INDEX idx_anniversaries_couple ON anniversaries(couple_id, base_date);

COMMENT ON TABLE anniversaries IS '한국식 기념일 관리 (D+100, D+200, 음력 생일)';
```

---

## Phase 3: 관계 발전 테이블

### 목표
- LLM 생성 대화 주제
- 관계 발전 활동 추천

### 테이블 구조

```sql
-- ============================================================
-- 3.1 conversation_topics (LLM 생성 대화 주제)
-- ============================================================
CREATE TABLE conversation_topics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,        -- ✅ couples.id 참조

  topic_category VARCHAR(100),    -- '미래 계획', '가족', '가치관', '추억'
  topic_title VARCHAR(200) NOT NULL,
  core_question TEXT NOT NULL,    -- 핵심 질문
  context_explanation TEXT,       -- 왜 지금 이 주제가 중요한지
  guide_questions TEXT[],         -- 세부 가이드 질문 3-5개

  conversation_depth_level INT,   -- 1~5 (얼마나 깊은 대화인지)
  estimated_time_minutes INT,     -- 예상 소요 시간

  generated_by VARCHAR(50) DEFAULT 'gpt-4',
  status VARCHAR(20) DEFAULT 'suggested', -- 'suggested', 'in_progress', 'completed', 'skipped'

  suggested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,

  -- 외래키
  CONSTRAINT fk_topic_couple
    FOREIGN KEY (couple_id)
    REFERENCES couples(id)
    ON DELETE CASCADE
);

CREATE INDEX idx_topics_couple ON conversation_topics(couple_id, suggested_at DESC);
CREATE INDEX idx_topics_status ON conversation_topics(status);

COMMENT ON TABLE conversation_topics IS 'GPT-4 생성 대화 주제 (기획서 섹션 5-4 참조)';


-- ============================================================
-- 3.2 topic_history (주제 탐색 기록)
-- ============================================================
CREATE TABLE topic_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,        -- ✅ couples.id 참조

  topic_category VARCHAR(100) NOT NULL,
  last_discussed_at TIMESTAMP WITH TIME ZONE,
  discussion_count INT DEFAULT 0,
  depth_score DECIMAL(3,2),       -- 얼마나 깊이 대화했는지 (0 ~ 1)

  -- 외래키
  CONSTRAINT fk_history_couple
    FOREIGN KEY (couple_id)
    REFERENCES couples(id)
    ON DELETE CASCADE,

  UNIQUE(couple_id, topic_category)
);

CREATE INDEX idx_topic_history_couple ON topic_history(couple_id, last_discussed_at DESC);

COMMENT ON TABLE topic_history IS '주제별 대화 이력 추적';


-- ============================================================
-- 3.3 activities (관계 발전 활동)
-- ============================================================
CREATE TABLE activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,        -- ✅ couples.id 참조

  activity_title VARCHAR(200) NOT NULL,
  activity_purpose TEXT,          -- 이 활동의 목적
  category VARCHAR(100),          -- '대화 촉진', '추억 만들기', '감정 표현'

  preparation_items TEXT[],       -- 준비물
  step_by_step_guide JSONB,       -- 단계별 진행 방법
  expected_outcome TEXT,          -- 기대 효과

  difficulty_level INT,           -- 1~5
  estimated_time_minutes INT,

  generated_by VARCHAR(50) DEFAULT 'gpt-4',
  status VARCHAR(20) DEFAULT 'suggested', -- 'suggested', 'in_progress', 'completed', 'skipped'

  suggested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  feedback_rating INT,            -- 1~5 (실행 후 사용자 평가)
  feedback_text TEXT,

  -- 외래키
  CONSTRAINT fk_activity_couple
    FOREIGN KEY (couple_id)
    REFERENCES couples(id)
    ON DELETE CASCADE
);

CREATE INDEX idx_activities_couple ON activities(couple_id, suggested_at DESC);
CREATE INDEX idx_activities_status ON activities(status);

COMMENT ON TABLE activities IS 'GPT-4 생성 관계 발전 활동 (기획서 섹션 5-4 참조)';


-- ============================================================
-- 3.4 conversation_summaries (일별 대화 요약)
-- ============================================================
CREATE TABLE conversation_summaries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,        -- ✅ couples.id 참조
  summary_date DATE NOT NULL,

  summary_text TEXT,              -- KoBART로 생성한 요약
  key_moments TEXT[],             -- 하이라이트 문장들
  total_messages INT,
  total_words INT,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- 외래키
  CONSTRAINT fk_summary_couple
    FOREIGN KEY (couple_id)
    REFERENCES couples(id)
    ON DELETE CASCADE,

  UNIQUE(couple_id, summary_date)
);

CREATE INDEX idx_summaries_couple ON conversation_summaries(couple_id, summary_date DESC);

COMMENT ON TABLE conversation_summaries IS 'KoBART 일별 대화 요약';
```

---

## Phase 4: 트렌드 & 건강 테이블

### 목표
- 감정 트렌드 분석
- 관계 건강도 추적
- 조기 경고 시스템

### 테이블 구조

```sql
-- ============================================================
-- 4.1 emotion_trends (감정 트렌드)
-- ============================================================
CREATE TABLE emotion_trends (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,        -- ✅ couples.id 참조

  period_type VARCHAR(20) NOT NULL, -- 'weekly', 'monthly'
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,

  emotion_distribution JSONB,     -- 7가지 감정별 비율
  trend_direction VARCHAR(20),    -- 'improving', 'stable', 'declining'
  positive_ratio_change DECIMAL(5,2), -- 긍정 감정 변화율 (%)

  analyzed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- 외래키
  CONSTRAINT fk_trend_couple
    FOREIGN KEY (couple_id)
    REFERENCES couples(id)
    ON DELETE CASCADE,

  UNIQUE(couple_id, period_type, period_start)
);

CREATE INDEX idx_trends_couple ON emotion_trends(couple_id, period_start DESC);

COMMENT ON TABLE emotion_trends IS '주간/월간 감정 트렌드 분석';


-- ============================================================
-- 4.2 relationship_health (관계 건강도)
-- ============================================================
CREATE TABLE relationship_health (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,        -- ✅ couples.id 참조
  health_date DATE NOT NULL,

  total_score DECIMAL(5,2),       -- 0 ~ 100
  emotion_score DECIMAL(5,2),     -- 감정 점수 (40% 가중치)
  lsm_score DECIMAL(5,2),         -- LSM 점수 (30% 가중치)
  balance_score DECIMAL(5,2),     -- 턴테이킹 균형 (30% 가중치)

  trend VARCHAR(20),              -- 'improving', 'stable', 'declining'

  calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- 외래키
  CONSTRAINT fk_health_couple
    FOREIGN KEY (couple_id)
    REFERENCES couples(id)
    ON DELETE CASCADE,

  UNIQUE(couple_id, health_date)
);

CREATE INDEX idx_health_couple ON relationship_health(couple_id, health_date DESC);

COMMENT ON TABLE relationship_health IS '관계 건강도 점수 (기획서 공식: 감정 40% + LSM 30% + 균형 30%)';


-- ============================================================
-- 4.3 conflict_alerts (갈등 조기 경고)
-- ============================================================
CREATE TABLE conflict_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,        -- ✅ couples.id 참조

  alert_type VARCHAR(50) NOT NULL,  -- 'negative_trend', 'reduced_communication', 'shallow_conversations'
  severity VARCHAR(20) NOT NULL,    -- 'low', 'medium', 'high'
  description TEXT NOT NULL,
  recommended_actions JSONB,        -- 추천 활동들

  detected_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  resolved_at TIMESTAMP WITH TIME ZONE,
  is_resolved BOOLEAN DEFAULT FALSE,

  -- 외래키
  CONSTRAINT fk_alert_couple
    FOREIGN KEY (couple_id)
    REFERENCES couples(id)
    ON DELETE CASCADE
);

CREATE INDEX idx_alerts_couple ON conflict_alerts(couple_id, detected_at DESC);
CREATE INDEX idx_alerts_unresolved ON conflict_alerts(is_resolved, detected_at DESC);

COMMENT ON TABLE conflict_alerts IS '조기 경고 시스템 (부정 감정 30% 초과, 대화 감소 등)';


-- ============================================================
-- 4.4 user_preferences (사용자 선호도 학습)
-- ============================================================
CREATE TABLE user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,          -- ✅ profiles.id 참조

  preference_type VARCHAR(50) NOT NULL, -- 'food', 'movie_genre', 'activity', 'music', 'travel'
  preference_value TEXT NOT NULL,
  confidence DECIMAL(3,2),        -- 학습 확신도

  learned_from_conversation_id UUID, -- ✅ conversations.id 참조
  learned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- 외래키
  CONSTRAINT fk_pref_user
    FOREIGN KEY (user_id)
    REFERENCES profiles(id)
    ON DELETE CASCADE,

  CONSTRAINT fk_pref_conversation
    FOREIGN KEY (learned_from_conversation_id)
    REFERENCES conversations(id)
    ON DELETE SET NULL,

  UNIQUE(user_id, preference_type, preference_value)
);

CREATE INDEX idx_preferences_user ON user_preferences(user_id, preference_type);

COMMENT ON TABLE user_preferences IS '대화에서 자동 학습한 사용자 선호도';
```

---

## 테이블 관계도

```
[기존 테이블]                    [AI 테이블]
┌─────────────┐
│conversations│─────┐
│  (기존)      │     │ FK
└─────────────┘     ├──→ analysis_results (감정 분석)
                    ├──→ ner_extractions (NER)
                    └──→ user_preferences (선호도)

┌─────────────┐
│   couples    │─────┐
│  (기존)      │     │ FK
└─────────────┘     ├──→ conversation_analysis (일별 분석)
                    ├──→ anniversaries (기념일)
                    ├──→ conversation_topics (대화 주제)
                    ├──→ topic_history (주제 기록)
                    ├──→ activities (활동)
                    ├──→ conversation_summaries (요약)
                    ├──→ emotion_trends (트렌드)
                    ├──→ relationship_health (건강도)
                    └──→ conflict_alerts (경고)

┌─────────────┐
│  profiles    │─────┐
│  (기존)      │     │ FK
└─────────────┘     └──→ user_preferences (선호도)
```

---

## Phase별 테이블 추가 순서

### Phase 0: 기존 테이블 보완
```sql
✅ conversations (컬럼 5개 추가)
   - message_type
   - audio_url
   - voice_tone_features
   - sentiment
   - emotion_score
```

### Phase 1: 대화 분석 (2개 테이블)
```sql
✅ analysis_results
✅ conversation_analysis
```

### Phase 2: 일정 관리 (2개 테이블)
```sql
✅ ner_extractions
✅ anniversaries
```

### Phase 3: 관계 발전 (4개 테이블)
```sql
✅ conversation_topics
✅ topic_history
✅ activities
✅ conversation_summaries
```

### Phase 4: 트렌드 & 건강 (4개 테이블)
```sql
✅ emotion_trends
✅ relationship_health
✅ conflict_alerts
✅ user_preferences
```

**총 12개 AI 전용 테이블**

---

## 다음 단계

1. ✅ 스키마 설계 완료
2. ⏭️ Phase별 마이그레이션 SQL 파일 작성
3. ⏭️ Supabase에 테이블 생성
4. ⏭️ RLS 정책 적용
5. ⏭️ AI 서비스 구현 시작

---

**작성일**: 2025-11-19
**기반**: 기획서 + ARCHITECTURE.md
**원칙**: 기존 테이블 수정 금지, AI 테이블만 추가

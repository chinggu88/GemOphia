-- ============================================================
-- Phase 1: 대화 분석 테이블
-- ============================================================
-- 생성일: 2025-11-19
-- 설명: AI 감정 분석 및 일별 대화 종합 분석
-- 기획서: 섹션 5 - (3) 대화 분석 엔진
-- ============================================================

-- ============================================================
-- 1.1 analysis_results (메시지별 감정 분석)
-- ============================================================
-- 목적: 각 메시지의 감정 분석 결과 저장
-- 연결: conversations.id → analysis_results.conversation_id
-- ============================================================

CREATE TABLE IF NOT EXISTS analysis_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL,

  -- 감정 분석 결과 (7가지 감정)
  emotion VARCHAR(50) NOT NULL,   -- '기쁨', '슬픔', '화남', '불안', '중립', '사랑', '피곤'
  confidence DECIMAL(3,2) CHECK (confidence >= 0.00 AND confidence <= 1.00),
  all_scores JSONB,               -- {"기쁨": 0.89, "슬픔": 0.02, "화남": 0.01, ...}

  -- 멀티모달 분석 (Phase 1.5에서 활용)
  voice_emotion JSONB,            -- 음성 톤 기반 감정 (선택적)

  -- 키워드 & 주제
  keywords TEXT[] DEFAULT '{}',   -- TextRank로 추출한 키워드
  topics TEXT[] DEFAULT '{}',     -- 대화 주제 태그

  -- 메타데이터
  processed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- 외래키 (기존 conversations 테이블 참조)
  CONSTRAINT fk_analysis_conversation
    FOREIGN KEY (conversation_id)
    REFERENCES conversations(id)
    ON DELETE CASCADE
);

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_analysis_conversation ON analysis_results(conversation_id);
CREATE INDEX IF NOT EXISTS idx_analysis_emotion ON analysis_results(emotion, processed_at DESC);
CREATE INDEX IF NOT EXISTS idx_analysis_processed_at ON analysis_results(processed_at DESC);

-- 코멘트
COMMENT ON TABLE analysis_results IS 'AI 감정 분석 결과 (메시지별) - Phase 1';
COMMENT ON COLUMN analysis_results.emotion IS '주요 감정 (Gemini API 또는 KoBERT)';
COMMENT ON COLUMN analysis_results.all_scores IS '7가지 감정 점수 JSON: {"기쁨": 0.89, "슬픔": 0.02, ...}';
COMMENT ON COLUMN analysis_results.voice_emotion IS '음성 톤 분석 결과 (멀티모달)';
COMMENT ON COLUMN analysis_results.keywords IS 'TextRank 또는 LLM으로 추출한 키워드';


-- ============================================================
-- 1.2 conversation_analysis (일별 대화 종합 분석)
-- ============================================================
-- 목적: 매일 23:59 배치 작업으로 생성되는 종합 분석
-- 연결: couples.id → conversation_analysis.couple_id
-- 배치: ai_backend/app/schedulers/daily_analysis.py
-- ============================================================

CREATE TABLE IF NOT EXISTS conversation_analysis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,
  analysis_date DATE NOT NULL,

  -- 감정 요약
  emotion_summary JSONB,          -- {"긍정": 0.65, "중립": 0.25, "부정": 0.10}
  dominant_emotion VARCHAR(50),   -- 가장 많이 나타난 감정

  -- LSM 분석 (Language Style Matching)
  lsm_score DECIMAL(3,2) CHECK (lsm_score >= 0.00 AND lsm_score <= 1.00),
  lsm_details JSONB,              -- {"대명사": 0.85, "조사": 0.72, "접속사": 0.68}

  -- 턴테이킹 분석 (대화 균형)
  turn_taking JSONB,              -- {"balance_score": 95.0, "turn_ratio": 0.475, "user_a_turns": 42, "user_b_turns": 46}

  -- 관계 건강도 (Phase 4에서 별도 테이블로 분리 예정)
  relationship_health DECIMAL(5,2) CHECK (relationship_health >= 0 AND relationship_health <= 100),

  -- 갈등 감지
  conflict_detected BOOLEAN DEFAULT FALSE,
  conflict_intensity DECIMAL(3,2) CHECK (conflict_intensity >= 0.00 AND conflict_intensity <= 1.00),

  -- 키워드
  keywords TEXT[] DEFAULT '{}',   -- 일별 핵심 키워드

  -- 메타데이터
  analyzed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- 외래키 (기존 couples 테이블 참조)
  CONSTRAINT fk_conv_analysis_couple
    FOREIGN KEY (couple_id)
    REFERENCES couples(id)
    ON DELETE CASCADE,

  -- 유니크 제약 (하루에 하나씩만)
  CONSTRAINT unique_couple_date UNIQUE(couple_id, analysis_date)
);

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_conv_analysis_couple ON conversation_analysis(couple_id, analysis_date DESC);
CREATE INDEX IF NOT EXISTS idx_conv_analysis_date ON conversation_analysis(analysis_date DESC);
CREATE INDEX IF NOT EXISTS idx_conv_analysis_conflict ON conversation_analysis(conflict_detected, analysis_date DESC);

-- 코멘트
COMMENT ON TABLE conversation_analysis IS '일별 대화 종합 분석 (LSM + 턴테이킹 + 감정) - Phase 1';
COMMENT ON COLUMN conversation_analysis.lsm_score IS 'Language Style Matching 점수 (0~1, 높을수록 대화 스타일 유사)';
COMMENT ON COLUMN conversation_analysis.turn_taking IS '대화 균형 분석 JSON';
COMMENT ON COLUMN conversation_analysis.relationship_health IS '관계 건강도 (0~100, 감정 40% + LSM 30% + 균형 30%)';
COMMENT ON COLUMN conversation_analysis.conflict_detected IS '갈등 감지 여부 (부정 감정 30% 초과 등)';


-- ============================================================
-- 함수: 감정 점수를 긍정/중립/부정으로 분류
-- ============================================================
-- 목적: emotion_summary 생성 시 사용
-- 사용: daily_analysis.py에서 호출
-- ============================================================

CREATE OR REPLACE FUNCTION calculate_emotion_category(emotion_name VARCHAR)
RETURNS VARCHAR AS $$
BEGIN
  RETURN CASE
    WHEN emotion_name IN ('기쁨', '사랑') THEN 'positive'
    WHEN emotion_name IN ('슬픔', '화남', '불안', '피곤') THEN 'negative'
    ELSE 'neutral'
  END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION calculate_emotion_category IS '감정을 긍정/중립/부정으로 분류';


-- ============================================================
-- 뷰: 최근 7일 감정 트렌드 (빠른 조회용)
-- ============================================================
-- 목적: Flutter 앱에서 대시보드 표시 시 사용
-- ============================================================

CREATE OR REPLACE VIEW recent_emotion_trends AS
SELECT
  ca.couple_id,
  ca.analysis_date,
  ca.emotion_summary,
  ca.dominant_emotion,
  ca.relationship_health,
  ca.conflict_detected
FROM conversation_analysis ca
WHERE ca.analysis_date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY ca.couple_id, ca.analysis_date DESC;

COMMENT ON VIEW recent_emotion_trends IS '최근 7일 감정 트렌드 (대시보드용)';


-- ============================================================
-- 초기 데이터 확인
-- ============================================================
-- 테이블 생성 확인용 (삭제해도 무방)
-- ============================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Phase 1 마이그레이션 완료';
  RAISE NOTICE '   - analysis_results 테이블 생성';
  RAISE NOTICE '   - conversation_analysis 테이블 생성';
  RAISE NOTICE '   - calculate_emotion_category 함수 생성';
  RAISE NOTICE '   - recent_emotion_trends 뷰 생성';
  RAISE NOTICE '';
  RAISE NOTICE '📊 테이블 확인:';
  RAISE NOTICE '   SELECT * FROM analysis_results LIMIT 1;';
  RAISE NOTICE '   SELECT * FROM conversation_analysis LIMIT 1;';
END $$;

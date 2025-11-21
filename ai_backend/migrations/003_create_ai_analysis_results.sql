-- Migration: Create ai_analysis_results table
-- Description: AI 분석 최종 결과 저장 (감정, LSM, turn-taking 등) - 플러터 앱에서 조회
-- Created: 2025-11-21

-- 분석 결과 테이블
CREATE TABLE IF NOT EXISTS ai_analysis_results (
  -- 기본 식별자
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  preprocessed_data_id UUID REFERENCES ai_preprocessed_data(id) ON DELETE CASCADE,
  couple_id UUID REFERENCES couples(id) ON DELETE CASCADE,

  -- 분석 타입
  analysis_type TEXT CHECK (analysis_type IN (
    'emotion',        -- 감정 분석
    'lsm',           -- Language Style Matching
    'turn_taking',   -- 대화 턴테이킹
    'topic',         -- 주제 분석
    'keyword',       -- 키워드 추출
    'summary',       -- 대화 요약
    'overall'        -- 종합 분석
  )) NOT NULL,

  -- 분석 결과 (JSONB - 각 분석 타입별로 다른 구조)
  analysis_result JSONB NOT NULL,

  -- 요약 및 인사이트
  summary TEXT,                    -- 분석 결과 요약
  insights JSONB,                  -- 주요 인사이트 배열
  recommendations JSONB,           -- 추천사항/조언

  -- 메타데이터
  confidence_score FLOAT,          -- 분석 신뢰도 (0.0 ~ 1.0)
  model_version TEXT,              -- 사용한 모델 버전
  analysis_config JSONB,           -- 분석 파라미터/설정

  -- 타임스탬프
  analyzed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX idx_analysis_couple ON ai_analysis_results(couple_id);
CREATE INDEX idx_analysis_preprocessed ON ai_analysis_results(preprocessed_data_id);
CREATE INDEX idx_analysis_type ON ai_analysis_results(analysis_type);
CREATE INDEX idx_analysis_couple_type ON ai_analysis_results(couple_id, analysis_type);

-- RLS (Row Level Security) 활성화
ALTER TABLE ai_analysis_results ENABLE ROW LEVEL SECURITY;

-- RLS 정책: 커플 멤버만 조회 가능
CREATE POLICY "Users can view their couple's analysis results"
  ON ai_analysis_results
  FOR SELECT
  USING (
    couple_id IN (
      SELECT id FROM couples
      WHERE user1_id = auth.uid() OR user2_id = auth.uid()
    )
  );

-- RLS 정책: AI 백엔드(service role)는 모든 작업 가능
CREATE POLICY "Service role can manage all analysis results"
  ON ai_analysis_results
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- 코멘트 추가
COMMENT ON TABLE ai_analysis_results IS 'AI 분석 최종 결과 (플러터 앱에서 조회)';
COMMENT ON COLUMN ai_analysis_results.analysis_type IS '분석 타입 (emotion, lsm, turn_taking, topic, keyword, summary, overall)';
COMMENT ON COLUMN ai_analysis_results.analysis_result IS '분석 결과 데이터 (각 타입별로 다른 구조)';
COMMENT ON COLUMN ai_analysis_results.insights IS '주요 인사이트 배열';
COMMENT ON COLUMN ai_analysis_results.recommendations IS '추천사항/조언';
COMMENT ON COLUMN ai_analysis_results.confidence_score IS '분석 신뢰도 (0.0 ~ 1.0)';

-- 예시 데이터 구조 코멘트
COMMENT ON COLUMN ai_analysis_results.analysis_result IS
'분석 결과 예시:
- emotion: {"positive": 0.7, "negative": 0.2, "neutral": 0.1, "emotions_over_time": [...]}
- lsm: {"overall_score": 0.85, "categories": {"pronouns": 0.9, "articles": 0.8, ...}}
- turn_taking: {"balance": 0.6, "user1_turns": 120, "user2_turns": 100, ...}
- topic: {"main_topics": ["일상", "데이트", "음식"], "topic_distribution": {...}}
- keyword: {"keywords": [{"word": "사랑", "count": 15, "importance": 0.9}, ...]}
- summary: {"summary_text": "...", "key_moments": [...]}';

-- Migration: Create ai_preprocessed_data table
-- Description: AI가 파일을 전처리한 결과 저장 (텍스트 추출, 대화 파싱)
-- Created: 2025-11-21

-- 전처리 결과 테이블
CREATE TABLE IF NOT EXISTS ai_preprocessed_data (
  -- 기본 식별자
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  file_id UUID REFERENCES ai_conversation_files(id) ON DELETE CASCADE,
  couple_id UUID REFERENCES couples(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,

  -- 처리 상태
  processing_status TEXT CHECK (processing_status IN ('pending', 'processing', 'completed', 'failed')) DEFAULT 'pending',

  -- 추출된 원본 텍스트 (전체)
  extracted_text TEXT,

  -- 파싱된 대화 데이터 (JSONB 배열)
  -- 예: [{"timestamp": "2024-01-01T12:00:00", "sender": "철수", "message": "안녕"}]
  parsed_conversations JSONB,

  -- 메타데이터
  total_messages INTEGER DEFAULT 0,
  participants JSONB,  -- ["철수", "영희"]
  date_range JSONB,    -- {"start": "2024-01-01T00:00:00", "end": "2024-01-31T23:59:59"}
  file_type TEXT,      -- 'kakao_txt', 'pdf', 'audio'

  -- 에러/경고
  error_message TEXT,
  warnings JSONB,  -- ["warning1", "warning2"]

  -- 타임스탬프
  processed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX idx_preprocessed_couple ON ai_preprocessed_data(couple_id);
CREATE INDEX idx_preprocessed_file ON ai_preprocessed_data(file_id);
CREATE INDEX idx_preprocessed_status ON ai_preprocessed_data(processing_status);
CREATE INDEX idx_preprocessed_user ON ai_preprocessed_data(user_id);

-- RLS (Row Level Security) 활성화
ALTER TABLE ai_preprocessed_data ENABLE ROW LEVEL SECURITY;

-- RLS 정책: 커플 멤버만 조회 가능
CREATE POLICY "Users can view their couple's preprocessed data"
  ON ai_preprocessed_data
  FOR SELECT
  USING (
    couple_id IN (
      SELECT id FROM couples
      WHERE user1_id = auth.uid() OR user2_id = auth.uid()
    )
  );

-- RLS 정책: AI 백엔드(service role)는 모든 작업 가능
CREATE POLICY "Service role can manage all preprocessed data"
  ON ai_preprocessed_data
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- 코멘트 추가
COMMENT ON TABLE ai_preprocessed_data IS 'AI가 파일을 전처리한 결과 저장 (텍스트 추출, 대화 파싱)';
COMMENT ON COLUMN ai_preprocessed_data.extracted_text IS '파일에서 추출한 원본 텍스트 전체';
COMMENT ON COLUMN ai_preprocessed_data.parsed_conversations IS '파싱된 대화 데이터 (timestamp, sender, message)';
COMMENT ON COLUMN ai_preprocessed_data.participants IS '대화 참여자 목록';
COMMENT ON COLUMN ai_preprocessed_data.date_range IS '대화 날짜 범위 (start, end)';

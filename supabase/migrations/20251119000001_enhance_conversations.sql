-- ============================================================
-- Phase 0: conversations 테이블 보완
-- ============================================================
-- 생성일: 2025-11-19
-- 설명: AI 기능을 위한 최소한의 컬럼 추가
-- 기획서: 섹션 5 - (1) 정보 관리 시스템
-- ============================================================

-- 1. message_type 컬럼 추가 (text/voice)
ALTER TABLE conversations
  ADD COLUMN IF NOT EXISTS message_type VARCHAR(20) DEFAULT 'text';

-- 2. audio_url 컬럼 추가 (음성 파일 경로)
ALTER TABLE conversations
  ADD COLUMN IF NOT EXISTS audio_url TEXT;

-- 3. voice_tone_features 컬럼 추가 (음성 분석 결과)
ALTER TABLE conversations
  ADD COLUMN IF NOT EXISTS voice_tone_features JSONB;

-- 4. sentiment 컬럼 추가 (감정 분석 결과)
ALTER TABLE conversations
  ADD COLUMN IF NOT EXISTS sentiment VARCHAR(50);

-- 5. emotion_score 컬럼 추가 (감정 점수)
ALTER TABLE conversations
  ADD COLUMN IF NOT EXISTS emotion_score INT;

-- 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_conversations_message_type
  ON conversations(message_type);

CREATE INDEX IF NOT EXISTS idx_conversations_sentiment
  ON conversations(sentiment, created_at DESC);

-- 코멘트 추가
COMMENT ON COLUMN conversations.message_type IS 'text 또는 voice';
COMMENT ON COLUMN conversations.audio_url IS 'Supabase Storage 음성 파일 URL (voice-messages bucket)';
COMMENT ON COLUMN conversations.voice_tone_features IS '음성 톤 분석 결과 JSON (선택적)';
COMMENT ON COLUMN conversations.sentiment IS 'AI 감정 분석 결과 (기쁨, 슬픔, 화남, 불안, 중립, 사랑, 피곤)';
COMMENT ON COLUMN conversations.emotion_score IS 'AI 감정 점수 (0-100)';

-- ============================================================
-- Phase 3: NER (개체명 인식) 및 일정 자동화 테이블
-- ============================================================

-- 1. ner_extractions 테이블 생성
CREATE TABLE IF NOT EXISTS ner_extractions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL,
  
  -- 추출된 개체명
  entity_type VARCHAR(50) NOT NULL, -- 'date', 'time', 'location', 'activity'
  entity_value TEXT NOT NULL,
  confidence DECIMAL(3,2),
  
  -- 메타데이터
  extracted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 외래키
  CONSTRAINT fk_ner_conversation
    FOREIGN KEY (conversation_id)
    REFERENCES conversations(id)
    ON DELETE CASCADE
);

-- 2. schedules 테이블 보완 (기존 테이블이 있다고 가정, 없으면 생성)
CREATE TABLE IF NOT EXISTS schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL,
  title TEXT NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE,
  end_time TIMESTAMP WITH TIME ZONE,
  location TEXT,
  description TEXT,
  
  -- 상태 (pending: AI 제안, confirmed: 사용자 확정)
  status VARCHAR(20) DEFAULT 'confirmed',
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_ner_conversation_id ON ner_extractions(conversation_id);
CREATE INDEX IF NOT EXISTS idx_schedules_couple_id ON schedules(couple_id);

-- ============================================================
-- Phase 4: Production Security (RLS Policies)
-- ============================================================

-- 1. 모든 테이블에 RLS 활성화
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE analysis_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_analysis ENABLE ROW LEVEL SECURITY;
ALTER TABLE ner_extractions ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE couples ENABLE ROW LEVEL SECURITY;

-- 2. Couples 테이블 정책
-- 커플 당사자만 볼 수 있음
CREATE POLICY "Couples visible to members"
ON couples FOR SELECT
USING (
  auth.uid() = user_a_id OR auth.uid() = user_b_id
);

-- 3. Conversations 테이블 정책
-- 커플 멤버만 대화 조회 가능
CREATE POLICY "Conversations visible to couple members"
ON conversations FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM couples
    WHERE id = conversations.couple_id
    AND (user_a_id = auth.uid() OR user_b_id = auth.uid())
  )
);

-- 본인만 메시지 작성 가능 (또는 커플 멤버)
CREATE POLICY "Users can insert messages"
ON conversations FOR INSERT
WITH CHECK (
  auth.uid() = sender_id
);

-- 4. Analysis Results (AI 분석 결과)
-- 커플 멤버만 조회 가능
CREATE POLICY "Analysis visible to couple members"
ON analysis_results FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM conversations
    JOIN couples ON conversations.couple_id = couples.id
    WHERE conversations.id = analysis_results.conversation_id
    AND (couples.user_a_id = auth.uid() OR couples.user_b_id = auth.uid())
  )
);

-- AI 백엔드(Service Role)는 모든 권한 가짐 (기본적으로 bypass RLS지만 명시적 정책이 필요할 수 있음)
-- Supabase Service Role은 RLS를 우회하므로 별도 정책 불필요

-- 5. Conversation Analysis (일별 분석)
CREATE POLICY "Daily analysis visible to couple members"
ON conversation_analysis FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM couples
    WHERE id = conversation_analysis.couple_id
    AND (user_a_id = auth.uid() OR user_b_id = auth.uid())
  )
);

-- 6. NER Extractions
CREATE POLICY "NER results visible to couple members"
ON ner_extractions FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM conversations
    JOIN couples ON conversations.couple_id = couples.id
    WHERE conversations.id = ner_extractions.conversation_id
    AND (couples.user_a_id = auth.uid() OR couples.user_b_id = auth.uid())
  )
);

-- 7. Schedules
CREATE POLICY "Schedules visible to couple members"
ON schedules FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM couples
    WHERE id = schedules.couple_id
    AND (user_a_id = auth.uid() OR user_b_id = auth.uid())
  )
);

CREATE POLICY "Couple members can create schedules"
ON schedules FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM couples
    WHERE id = schedules.couple_id
    AND (user_a_id = auth.uid() OR user_b_id = auth.uid())
  )
);

CREATE POLICY "Couple members can update schedules"
ON schedules FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM couples
    WHERE id = schedules.couple_id
    AND (user_a_id = auth.uid() OR user_b_id = auth.uid())
  )
);

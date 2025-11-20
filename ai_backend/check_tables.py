"""
Supabase 데이터베이스 테이블 구조 확인 스크립트
"""
from app.core.config import get_settings
from app.core.supabase import get_supabase_client


def check_tables():
    """현재 Supabase 데이터베이스의 테이블 목록과 구조 확인"""

    print("=" * 80)
    print("🔍 Supabase 데이터베이스 테이블 구조 확인")
    print("=" * 80)

    try:
        settings = get_settings()
        supabase = get_supabase_client()

        print(f"\n✅ Supabase 연결 성공!")
        print(f"   URL: {settings.supabase_url}")
        print(f"   AI Provider: {settings.ai_provider}")

        # 1. 테이블 목록 조회 (개별 테이블 확인)
        print("\n" + "=" * 80)
        print("📋 테이블 존재 여부 확인")
        print("=" * 80)

        # ARCHITECTURE.md에 정의된 테이블 목록
        expected_tables = [
            'messages', 'ner_extractions', 'analysis_results',
            'conversation_summaries', 'conversation_analysis', 'emotion_trends',
            'schedules', 'anniversaries', 'calendar_events',
            'conversation_topics', 'topic_history', 'activities',
            'relationship_health', 'conflict_alerts', 'user_preferences'
        ]

        print("\n📊 예상 테이블 존재 여부 확인:")
        existing_tables = []

        for table in expected_tables:
            try:
                # 테이블이 존재하는지 확인 (빈 쿼리)
                supabase.table(table).select('*').limit(0).execute()
                print(f"   ✅ {table}")
                existing_tables.append(table)
            except Exception as e:
                print(f"   ❌ {table} - {str(e)[:50]}...")

        print(f"\n총 {len(existing_tables)}/{len(expected_tables)}개 테이블 존재")

        # 2. 각 테이블의 샘플 데이터 확인
        if existing_tables:
            print("\n" + "=" * 80)
            print("📊 각 테이블의 데이터 개수")
            print("=" * 80)

            for table in existing_tables:
                try:
                    result = supabase.table(table).select('*', count='exact').limit(0).execute()
                    count = result.count if hasattr(result, 'count') else 'Unknown'
                    print(f"   {table}: {count}개")
                except Exception as e:
                    print(f"   {table}: Error - {str(e)[:50]}...")

        return existing_tables

    except Exception as e:
        print(f"\n❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()
        return []


if __name__ == "__main__":
    existing_tables = check_tables()

    print("\n" + "=" * 80)
    print("📝 다음 단계:")
    print("=" * 80)

    if not existing_tables:
        print("""
1. Supabase Dashboard → SQL Editor로 이동
2. ARCHITECTURE.md에 정의된 테이블 생성 SQL 실행
3. 다시 이 스크립트 실행하여 확인
        """)
    else:
        print("""
1. 존재하는 테이블과 ARCHITECTURE.md 스키마 비교
2. 누락된 테이블 확인
3. AI 파이프라인 구현 시작
        """)

    print("=" * 80)

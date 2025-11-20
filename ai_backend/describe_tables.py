"""
Supabase 테이블 스키마 상세 조회
"""
from app.core.config import get_settings
from app.core.supabase import get_supabase_client


def describe_tables():
    """각 테이블의 컬럼 정보 조회"""

    print("=" * 80)
    print("🔍 Supabase 테이블 스키마 상세 조회")
    print("=" * 80)

    try:
        settings = get_settings()
        supabase = get_supabase_client()

        # 발견된 테이블 목록
        tables = ['conversations', 'couples', 'profiles', 'schedules']

        for table_name in tables:
            print(f"\n{'=' * 80}")
            print(f"📋 {table_name.upper()} 테이블")
            print("=" * 80)

            try:
                # 빈 레코드로 스키마 확인 시도
                result = supabase.table(table_name).select('*').limit(1).execute()

                if result.data and len(result.data) > 0:
                    # 데이터가 있으면 실제 레코드로 스키마 확인
                    record = result.data[0]
                    print(f"\n컬럼 목록 ({len(record)}개):")
                    for idx, (key, value) in enumerate(record.items(), 1):
                        value_type = type(value).__name__
                        value_sample = str(value)[:50] if value else 'NULL'
                        print(f"   {idx:2}. {key:25} {value_type:15} = {value_sample}")
                else:
                    # 데이터가 없으면 INSERT 시도 후 에러 메시지로 컬럼 확인
                    print("\n⚠️ 데이터가 없습니다. 스키마 정보를 가져올 수 없습니다.")
                    print("   Supabase Dashboard에서 Table Editor로 확인하세요.")

            except Exception as e:
                error_msg = str(e)
                print(f"\n❌ 조회 실패: {error_msg[:200]}")

        # ARCHITECTURE.md와 비교
        print("\n" + "=" * 80)
        print("📊 ARCHITECTURE.md와 비교")
        print("=" * 80)

        print("\n✅ 존재하는 테이블:")
        print("   - conversations (대화 데이터?)")
        print("   - couples (커플 정보)")
        print("   - profiles (사용자 프로필)")
        print("   - schedules (일정 - ARCHITECTURE.md에 정의됨)")

        print("\n❌ ARCHITECTURE.md에는 정의되었으나 없는 테이블:")
        missing_from_arch = [
            'messages', 'ner_extractions', 'analysis_results',
            'conversation_summaries', 'conversation_analysis', 'emotion_trends',
            'anniversaries', 'calendar_events',
            'conversation_topics', 'topic_history', 'activities',
            'relationship_health', 'conflict_alerts', 'user_preferences'
        ]

        for table in missing_from_arch:
            print(f"   - {table}")

        print("\n⚠️ 추가로 존재하는 테이블 (ARCHITECTURE.md에 없음):")
        additional_tables = ['conversations', 'couples', 'profiles']
        for table in additional_tables:
            print(f"   - {table}")

    except Exception as e:
        print(f"\n❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    describe_tables()

    print("\n" + "=" * 80)
    print("💡 다음 단계")
    print("=" * 80)
    print("""
1. Supabase Dashboard → Table Editor에서 테이블 구조 확인
2. 'conversations' 테이블이 ARCHITECTURE.md의 'messages' 역할인지 확인
3. ARCHITECTURE.md 업데이트 또는 테이블 추가 생성 결정
    """)
    print("=" * 80)

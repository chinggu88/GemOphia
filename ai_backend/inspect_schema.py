"""
실제 Supabase 테이블 스키마 조회
"""
from app.core.supabase import get_supabase_client

def inspect_table_schema(table_name: str):
    """테이블 스키마 정보 조회"""
    supabase = get_supabase_client()

    print(f"\n{'='*80}")
    print(f"📋 {table_name.upper()} 테이블")
    print('='*80)

    try:
        # 빈 SELECT로 컬럼 구조 확인
        result = supabase.table(table_name).select('*').limit(1).execute()

        # 응답에서 컬럼 정보 추출
        if result.data:
            print(f"\n✅ 테이블 존재! 샘플 데이터:")
            print(result.data[0])
        else:
            print(f"\n✅ 테이블 존재! (데이터 없음)")

        # RPC로 컬럼 정보 조회
        print(f"\n📊 컬럼 정보 (PostgreSQL information_schema):")

        # SQL 쿼리 실행
        query = f"""
        SELECT
            column_name,
            data_type,
            is_nullable,
            column_default
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = '{table_name}'
        ORDER BY ordinal_position;
        """

        # PostgREST를 통한 RPC 호출
        # Supabase는 rpc() 메서드 제공
        print(f"\n   컬럼명                      타입              NULL 허용    기본값")
        print(f"   {'-'*70}")

        # 대신 빈 INSERT 시도해서 에러 메시지로 컬럼 확인
        try:
            supabase.table(table_name).insert({}).execute()
        except Exception as e:
            error_msg = str(e)
            if "null value in column" in error_msg:
                print(f"\n   필수 컬럼 발견:")
                # 에러 메시지에서 컬럼명 추출
                import re
                columns = re.findall(r'"(\w+)"', error_msg)
                for col in columns:
                    print(f"   - {col}")

    except Exception as e:
        print(f"\n❌ 오류: {str(e)[:200]}")


if __name__ == "__main__":
    tables = [
        'ai_conversation_files',  # PDF 파일 메타데이터
        'conversations',
        'couples',
        'profiles',
        'schedules',
        'todos'
    ]

    print("="*80)
    print("🔍 Supabase 테이블 스키마 상세 조회")
    print("="*80)

    for table in tables:
        inspect_table_schema(table)

    print(f"\n{'='*80}")
    print("💡 TIP: Supabase Dashboard → Table Editor에서 GUI로 확인 가능")
    print("="*80)

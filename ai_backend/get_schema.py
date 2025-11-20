"""
Supabase 테이블 스키마 정보 조회 (OpenAPI 사용)
"""
import requests
from app.core.config import get_settings


def get_schema_info():
    """Supabase REST API의 OpenAPI 스펙을 통해 스키마 조회"""

    print("=" * 80)
    print("🔍 Supabase 테이블 스키마 정보 조회")
    print("=" * 80)

    try:
        settings = get_settings()

        # Supabase REST API의 OpenAPI 스펙 엔드포인트
        openapi_url = f"{settings.supabase_url}/rest/v1/"

        headers = {
            "apikey": settings.supabase_key,
            "Authorization": f"Bearer {settings.supabase_key}"
        }

        print(f"\n✅ Supabase 연결 중...")
        print(f"   URL: {settings.supabase_url}")

        # OpenAPI 스펙 가져오기
        response = requests.get(openapi_url, headers=headers)

        if response.status_code == 200:
            # OpenAPI JSON 응답에서 스키마 정보 추출
            openapi_spec = response.json()

            # definitions 또는 components/schemas에서 테이블 정보 추출
            if 'definitions' in openapi_spec:
                schemas = openapi_spec['definitions']
            elif 'components' in openapi_spec and 'schemas' in openapi_spec['components']:
                schemas = openapi_spec['components']['schemas']
            else:
                schemas = {}

            if schemas:
                print(f"\n✅ {len(schemas)}개 스키마 발견!\n")

                for table_name, schema_info in sorted(schemas.items()):
                    print("=" * 80)
                    print(f"📋 {table_name.upper()}")
                    print("=" * 80)

                    if 'properties' in schema_info:
                        properties = schema_info['properties']
                        required_fields = schema_info.get('required', [])

                        print(f"\n컬럼: {len(properties)}개")
                        print(f"필수 컬럼: {len(required_fields)}개\n")

                        for idx, (col_name, col_info) in enumerate(sorted(properties.items()), 1):
                            col_type = col_info.get('type', 'unknown')
                            col_format = col_info.get('format', '')
                            is_required = '✅ 필수' if col_name in required_fields else '  선택'

                            # 타입 정보 상세화
                            type_info = col_type
                            if col_format:
                                type_info = f"{col_type} ({col_format})"

                            # description이 있으면 출력
                            description = col_info.get('description', '')

                            print(f"  {idx:2}. {is_required} {col_name:30} {type_info:20}")

                            # 추가 정보 (enum, maxLength 등)
                            if 'enum' in col_info:
                                print(f"       → enum: {col_info['enum']}")
                            if 'maxLength' in col_info:
                                print(f"       → maxLength: {col_info['maxLength']}")
                            if description:
                                print(f"       → {description}")

                        print()
                    else:
                        print("   (스키마 정보 없음)\n")

                return schemas
            else:
                print("\n⚠️ OpenAPI 스펙에서 스키마를 찾을 수 없습니다.")
                print("   다른 방법을 시도합니다...\n")
                return None
        else:
            print(f"\n❌ OpenAPI 스펙 조회 실패: {response.status_code}")
            print(f"   응답: {response.text[:200]}")
            return None

    except Exception as e:
        print(f"\n❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()
        return None


def get_schema_via_sql():
    """PostgreSQL information_schema를 통해 스키마 조회"""

    print("\n" + "=" * 80)
    print("🔍 PostgreSQL information_schema 조회 시도")
    print("=" * 80)

    try:
        from app.core.supabase import get_supabase_client
        supabase = get_supabase_client()

        # 발견된 테이블 목록
        tables = ['conversations', 'couples', 'profiles', 'schedules', 'todos']

        for table_name in tables:
            print(f"\n{'=' * 80}")
            print(f"📋 {table_name.upper()}")
            print("=" * 80)

            # 각 테이블에 빈 INSERT 시도해서 에러 메시지로 컬럼 확인
            # 또는 OPTIONS 요청으로 메타데이터 가져오기

            try:
                # 1개 레코드만 조회 (있으면)
                result = supabase.table(table_name).select('*').limit(1).execute()

                # HEAD 요청으로 컬럼 정보 추출
                # Supabase는 SELECT *를 하면 모든 컬럼을 반환

                print(f"\n⚠️ 데이터가 없어서 스키마를 추론할 수 없습니다.")
                print(f"   테스트 데이터를 INSERT하거나 Supabase Dashboard를 사용하세요.\n")

            except Exception as e:
                error_msg = str(e)
                print(f"\n❌ 조회 실패: {error_msg[:200]}\n")

    except Exception as e:
        print(f"\n❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    # 방법 1: OpenAPI 스펙 사용
    schemas = get_schema_info()

    # 방법 1이 실패하면 방법 2 시도
    if not schemas:
        get_schema_via_sql()

    print("\n" + "=" * 80)
    print("💡 TIP")
    print("=" * 80)
    print("""
스키마 정보를 확인하는 다른 방법:

1. Supabase Dashboard
   → Table Editor에서 각 테이블 클릭
   → 컬럼 구조 직접 확인

2. SQL Editor에서 쿼리 실행:
   SELECT column_name, data_type, is_nullable
   FROM information_schema.columns
   WHERE table_name = 'conversations'
   ORDER BY ordinal_position;

3. 테스트 데이터 INSERT 후 구조 확인
    """)
    print("=" * 80)

"""
실제 Supabase 테이블 스키마 조회
"""
import sys
from pathlib import Path

# ai_backend 디렉토리를 Python 경로에 추가
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.core.supabase import get_supabase_client

def inspect_table_schema(table_name: str):
    """테이블 스키마 정보 조회"""
    supabase = get_supabase_client()

    print(f"\n{'='*100}")
    print(f"📋 {table_name.upper()} 테이블")
    print('='*100)

    try:
        # 샘플 데이터 조회
        result = supabase.table(table_name).select('*').limit(1).execute()

        if result.data:
            print(f"\n✅ 테이블 존재! 데이터 {len(result.data)}개")

            # 컬럼 정보 출력
            print(f"\n{'컬럼명':<30} {'타입 (추정)':<20} {'샘플 값':<40}")
            print('-' * 100)

            sample_data = result.data[0]
            for col_name, value in sample_data.items():
                # 타입 추정
                if value is None:
                    col_type = 'NULL'
                elif isinstance(value, bool):
                    col_type = 'BOOLEAN'
                elif isinstance(value, int):
                    col_type = 'INTEGER/BIGINT'
                elif isinstance(value, float):
                    col_type = 'NUMERIC/FLOAT'
                elif isinstance(value, str):
                    if 'T' in value and 'Z' in value or '+' in value:
                        col_type = 'TIMESTAMP'
                    else:
                        col_type = 'TEXT/VARCHAR'
                elif isinstance(value, dict):
                    col_type = 'JSONB'
                elif isinstance(value, list):
                    col_type = 'ARRAY/JSONB'
                else:
                    col_type = type(value).__name__

                # 샘플 값 (너무 길면 자르기)
                value_str = str(value)
                if len(value_str) > 37:
                    value_str = value_str[:34] + '...'

                print(f"{col_name:<30} {col_type:<20} {value_str:<40}")

        else:
            print(f"\n✅ 테이블 존재! (데이터 없음)")
            print("\n⚠️  데이터가 없어서 컬럼 정보를 추정할 수 없습니다.")
            print("    Supabase Dashboard → Table Editor에서 확인하세요.")

    except Exception as e:
        print(f"\n❌ 오류: {str(e)[:200]}")


if __name__ == "__main__":
    # AI 파일 업로드 파이프라인
    ai_tables = [
        'ai_conversation_files',  # 파일 메타데이터
        'ai_preprocessed_data',   # 전처리 결과
        'ai_analysis_results',    # AI 분석 결과
    ]

    # 기존 Flutter 앱 테이블
    app_tables = [
        'conversations',
        'couples',
        'profiles',
        'schedules',
        'todos'
    ]

    print("="*100)
    print("🔍 Supabase 테이블 스키마 상세 조회")
    print("="*100)

    print("\n" + "="*100)
    print("📦 AI 파이프라인 테이블 (파일 업로드 기반)")
    print("="*100)
    for table in ai_tables:
        inspect_table_schema(table)

    print("\n" + "="*100)
    print("📱 Flutter 앱 테이블")
    print("="*100)
    for table in app_tables:
        inspect_table_schema(table)

    print(f"\n{'='*100}")
    print("💡 TIP: Supabase Dashboard → Table Editor에서 GUI로 확인 가능")
    print("="*100)

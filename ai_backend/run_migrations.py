"""
마이그레이션 실행 스크립트

Supabase에 SQL 마이그레이션 파일을 직접 실행합니다.
"""
import os
from pathlib import Path
from app.core.supabase import get_supabase_client

def run_migration(sql_file_path: str):
    """
    SQL 파일을 읽어서 Supabase에 실행

    Args:
        sql_file_path: SQL 파일 경로
    """
    print(f"\n{'='*80}")
    print(f"🔄 Running migration: {Path(sql_file_path).name}")
    print('='*80)

    # SQL 파일 읽기
    with open(sql_file_path, 'r', encoding='utf-8') as f:
        sql_content = f.read()

    # Supabase 클라이언트
    supabase = get_supabase_client()

    try:
        # SQL 실행 (RPC를 통한 실행)
        # Supabase Python 클라이언트는 직접 SQL 실행을 지원하지 않으므로
        # postgrest를 통해 실행해야 합니다.

        # 더 나은 방법: psycopg2를 사용한 직접 연결
        import psycopg2
        from app.core.config import get_settings

        settings = get_settings()

        # PostgreSQL 연결 문자열 구성
        # Supabase의 경우: postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres

        print("\n⚠️  Direct SQL execution requires database connection string.")
        print("For now, please run this SQL manually in Supabase Dashboard → SQL Editor")
        print("\nSQL Content Preview:")
        print("-" * 80)
        print(sql_content[:500] + "..." if len(sql_content) > 500 else sql_content)
        print("-" * 80)

        return False

    except Exception as e:
        print(f"\n❌ Migration failed: {e}")
        return False

def main():
    """메인 함수"""
    migrations_dir = Path(__file__).parent / 'migrations'

    # 실행할 마이그레이션 파일 목록
    migration_files = [
        '002_create_ai_preprocessed_data.sql',
        '003_create_ai_analysis_results.sql',
    ]

    print("="*80)
    print("🚀 Supabase Migration Runner")
    print("="*80)

    for migration_file in migration_files:
        file_path = migrations_dir / migration_file

        if not file_path.exists():
            print(f"\n⚠️  File not found: {migration_file}")
            continue

        run_migration(str(file_path))

    print("\n" + "="*80)
    print("💡 TIP: Copy the SQL content and run it in Supabase Dashboard → SQL Editor")
    print("="*80)

if __name__ == "__main__":
    main()

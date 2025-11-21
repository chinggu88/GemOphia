"""
ai_conversation_files 테이블의 실제 컬럼 확인
"""
from app.core.supabase import get_supabase_client
import json

def check_table_structure():
    supabase = get_supabase_client()

    print("=" * 80)
    print("📋 AI_CONVERSATION_FILES 테이블 상세 정보")
    print("=" * 80)

    # 샘플 데이터 1개 조회
    result = supabase.table('ai_conversation_files') \
        .select('*') \
        .limit(1) \
        .execute()

    if result.data and len(result.data) > 0:
        sample = result.data[0]

        print("\n✅ 테이블 컬럼 목록:")
        print("-" * 80)
        for key, value in sample.items():
            value_type = type(value).__name__
            value_preview = str(value)[:50] if value else "NULL"
            print(f"  {key:25} | {value_type:15} | {value_preview}")

        print("\n" + "=" * 80)
        print("📄 샘플 데이터 (JSON):")
        print("=" * 80)
        print(json.dumps(sample, indent=2, default=str, ensure_ascii=False))

    else:
        print("⚠️ 테이블에 데이터가 없습니다")

if __name__ == "__main__":
    check_table_structure()

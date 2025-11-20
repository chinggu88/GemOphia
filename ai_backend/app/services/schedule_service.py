import logging
from datetime import datetime, timedelta
from typing import List, Optional
from ..core.supabase import get_supabase_client
from .ner_service import NEREntity

logger = logging.getLogger(__name__)

class ScheduleService:
    def __init__(self):
        self.supabase = get_supabase_client()

    async def create_pending_schedule(self, couple_id: str, entities: List[NEREntity], original_text: str):
        """
        추출된 개체명을 바탕으로 일정 후보를 생성합니다.
        날짜(date)와 활동(activity)이 모두 존재할 때만 생성합니다.
        """
        date_entity = next((e for e in entities if e.type == 'date'), None)
        activity_entity = next((e for e in entities if e.type == 'activity'), None)
        time_entity = next((e for e in entities if e.type == 'time'), None)
        location_entity = next((e for e in entities if e.type == 'location'), None)

        if not date_entity or not activity_entity:
            return

        # 날짜/시간 파싱 (단순화된 로직)
        # 실제로는 더 정교한 파서가 필요함
        try:
            start_time_str = f"{date_entity.value}"
            if time_entity:
                start_time_str += f" {time_entity.value}"
            else:
                start_time_str += " 12:00:00" # 기본 시간
            
            # ISO 포맷 변환 시도 (예외 처리 필요)
            # 여기서는 문자열 그대로 저장하거나 간단한 변환만 수행
            
            schedule_data = {
                'couple_id': couple_id,
                'title': activity_entity.value,
                'description': f"AI가 대화에서 추출한 일정입니다.\n원문: {original_text}",
                'location': location_entity.value if location_entity else None,
                'start_time': start_time_str, # 포맷이 맞아야 함 (YYYY-MM-DD HH:MM:SS)
                'status': 'pending'
            }

            self.supabase.table('schedules').insert(schedule_data).execute()
            logger.info(f"📅 Auto-schedule created: {activity_entity.value} on {date_entity.value}")

        except Exception as e:
            logger.error(f"Failed to create auto-schedule: {e}")

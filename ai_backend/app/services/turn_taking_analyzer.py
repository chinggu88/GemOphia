"""
Turn-Taking Analysis
Analyzes conversation balance and dynamics
"""
from collections import defaultdict
from datetime import datetime
import numpy as np
from ..models.schemas import TurnTakingAnalysis


class TurnTakingAnalyzer:
    """
    대화 턴테이킹 분석기

    대화의 균형, 응답 시간, 메시지 길이 등을 분석하여
    대화의 건강성을 평가합니다.
    """

    def analyze_conversation(self, messages: list[dict]) -> TurnTakingAnalysis:
        """
        대화 턴테이킹 분석

        Args:
            messages: [{sender_id, content, timestamp}, ...] 형태의 메시지 리스트

        Returns:
            TurnTakingAnalysis: 턴테이킹 분석 결과
        """
        if len(messages) < 2:
            # 메시지가 너무 적으면 기본값 반환
            return TurnTakingAnalysis(
                balance_score=50.0,
                turn_ratio=0.5,
                avg_response_time=0.0,
                interruption_rate=0.0
            )

        # 사용자별 메시지 통계
        user_stats = defaultdict(lambda: {
            'count': 0,
            'total_length': 0,
            'timestamps': []
        })

        for msg in messages:
            sender = msg['sender_id']
            user_stats[sender]['count'] += 1
            user_stats[sender]['total_length'] += len(msg.get('content', ''))
            if 'timestamp' in msg:
                ts = msg['timestamp']
                if isinstance(ts, str):
                    ts = datetime.fromisoformat(ts.replace('Z', '+00:00'))
                user_stats[sender]['timestamps'].append(ts)

        # 두 사용자 확인
        users = list(user_stats.keys())
        if len(users) != 2:
            return TurnTakingAnalysis(
                balance_score=50.0,
                turn_ratio=0.5,
                avg_response_time=0.0
            )

        # 1. 턴 비율 계산
        user_a_count = user_stats[users[0]]['count']
        user_b_count = user_stats[users[1]]['count']
        total_count = user_a_count + user_b_count

        turn_ratio = user_a_count / total_count if total_count > 0 else 0.5

        # 2. 균형 점수 계산 (0-100)
        # 완벽한 균형(50:50)에서 벗어날수록 점수 감소
        balance_score = 100 - abs(50 - turn_ratio * 100) * 2
        balance_score = max(0, min(100, balance_score))

        # 3. 평균 응답 시간 계산 (초 단위)
        response_times = []
        for i in range(1, len(messages)):
            prev_msg = messages[i - 1]
            curr_msg = messages[i]

            # 다른 사람이 응답한 경우만 계산
            if prev_msg['sender_id'] != curr_msg['sender_id']:
                if 'timestamp' in prev_msg and 'timestamp' in curr_msg:
                    prev_ts = prev_msg['timestamp']
                    curr_ts = curr_msg['timestamp']

                    if isinstance(prev_ts, str):
                        prev_ts = datetime.fromisoformat(prev_ts.replace('Z', '+00:00'))
                    if isinstance(curr_ts, str):
                        curr_ts = datetime.fromisoformat(curr_ts.replace('Z', '+00:00'))

                    time_diff = (curr_ts - prev_ts).total_seconds()
                    if 0 < time_diff < 3600:  # 1시간 이내만 계산 (비정상적 지연 제외)
                        response_times.append(time_diff)

        avg_response_time = np.mean(response_times) if response_times else 0.0

        # 4. 인터럽션 비율 계산 (연속 메시지)
        interruptions = 0
        for i in range(1, len(messages)):
            if messages[i]['sender_id'] == messages[i - 1]['sender_id']:
                interruptions += 1

        interruption_rate = interruptions / len(messages) if len(messages) > 0 else 0.0

        return TurnTakingAnalysis(
            balance_score=round(balance_score, 2),
            turn_ratio=round(turn_ratio, 3),
            avg_response_time=round(avg_response_time, 2),
            interruption_rate=round(interruption_rate, 3)
        )

    def get_balance_interpretation(self, balance_score: float) -> str:
        """
        균형 점수 해석

        Args:
            balance_score: 균형 점수 (0-100)

        Returns:
            str: 점수에 대한 해석
        """
        if balance_score >= 90:
            return "완벽한 대화 균형! 두 사람 모두 적극적으로 참여하고 있습니다."
        elif balance_score >= 75:
            return "좋은 대화 균형입니다. 서로 고르게 대화하고 있어요."
        elif balance_score >= 60:
            return "보통 수준의 균형입니다. 조금 더 균형을 맞춰보세요."
        elif balance_score >= 40:
            return "대화가 한쪽으로 치우쳐 있습니다. 상대방의 참여를 독려해보세요."
        else:
            return "대화 균형이 매우 불균형합니다. 소통 방식 개선이 필요합니다."

    def get_response_time_interpretation(self, avg_response_time: float) -> str:
        """
        응답 시간 해석

        Args:
            avg_response_time: 평균 응답 시간 (초)

        Returns:
            str: 응답 시간에 대한 해석
        """
        minutes = avg_response_time / 60

        if minutes < 1:
            return "매우 빠른 응답 - 활발한 대화를 나누고 있어요!"
        elif minutes < 5:
            return "빠른 응답 - 좋은 호응도입니다."
        elif minutes < 15:
            return "보통 응답 속도 - 평범한 수준입니다."
        elif minutes < 60:
            return "다소 느린 응답 - 바쁘신가요?"
        else:
            return "매우 느린 응답 - 더 자주 대화해보세요."

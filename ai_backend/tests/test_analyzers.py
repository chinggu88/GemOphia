from unittest.mock import MagicMock, patch
import pytest
from datetime import datetime, timedelta
from app.services.lsm_analyzer import LSMAnalyzer
from app.services.turn_taking_analyzer import TurnTakingAnalyzer

@pytest.fixture
def lsm_analyzer():
    with patch('app.services.lsm_analyzer.LSMAnalyzer') as MockAnalyzer:
        # Create a real instance but with mocked kiwi
        analyzer = LSMAnalyzer()
        analyzer.kiwi = MagicMock()
        
        # Mock tokenize to return dummy tokens based on input
        def mock_tokenize(text):
            tokens = []
            words = text.split()
            for word in words:
                token = MagicMock()
                token.form = word
                tokens.append(token)
            return tokens
            
        analyzer.kiwi.tokenize.side_effect = mock_tokenize
        return analyzer

@pytest.fixture
def turn_taking_analyzer():
    return TurnTakingAnalyzer()

def test_lsm_analyzer_basic(lsm_analyzer):
    # Case 1: Similar style (high LSM)
    # A: 나는 오늘 학교에 갔어. (나, 에)
    # B: 나는 어제 회사에 갔어. (나, 에)
    messages = [
        {'sender_id': 'user1', 'content': '나는 오늘 학교에 갔어.'},
        {'sender_id': 'user2', 'content': '나는 어제 회사에 갔어.'}
    ]
    result = lsm_analyzer.analyze_conversation(messages)
    assert result.lsm_score > 0.7
    
    # Case 2: Different style (low LSM)
    # A: (Function words) 나는 너를 좋아해.
    # B: (Content words only) 사과. 배. 포도.
    messages_diff = [
        {'sender_id': 'user1', 'content': '나는 너를 정말 좋아해.'},
        {'sender_id': 'user2', 'content': '사과 배 포도 수박.'}
    ]
    result_diff = lsm_analyzer.analyze_conversation(messages_diff)
    assert result_diff.lsm_score < result.lsm_score

def test_turn_taking_balance(turn_taking_analyzer):
    # Case 1: Perfect balance
    messages = [
        {'sender_id': 'user1', 'content': 'A', 'timestamp': '2023-01-01T10:00:00'},
        {'sender_id': 'user2', 'content': 'B', 'timestamp': '2023-01-01T10:00:10'},
        {'sender_id': 'user1', 'content': 'A', 'timestamp': '2023-01-01T10:00:20'},
        {'sender_id': 'user2', 'content': 'B', 'timestamp': '2023-01-01T10:00:30'},
    ]
    result = turn_taking_analyzer.analyze_conversation(messages)
    assert result.balance_score > 90
    assert result.turn_ratio == 0.5

    # Case 2: Imbalance
    messages_imbalance = [
        {'sender_id': 'user1', 'content': 'A', 'timestamp': '2023-01-01T10:00:00'},
        {'sender_id': 'user1', 'content': 'A', 'timestamp': '2023-01-01T10:00:01'},
        {'sender_id': 'user1', 'content': 'A', 'timestamp': '2023-01-01T10:00:02'},
        {'sender_id': 'user2', 'content': 'B', 'timestamp': '2023-01-01T10:00:10'},
    ]
    result_imbalance = turn_taking_analyzer.analyze_conversation(messages_imbalance)
    assert result_imbalance.balance_score < 90
    assert result_imbalance.turn_ratio != 0.5

def test_response_time(turn_taking_analyzer):
    base_time = datetime(2023, 1, 1, 10, 0, 0)
    messages = [
        {'sender_id': 'user1', 'content': 'Hi', 'timestamp': base_time.isoformat()},
        {'sender_id': 'user2', 'content': 'Hello', 'timestamp': (base_time + timedelta(seconds=60)).isoformat()}, # 60s delay
        {'sender_id': 'user1', 'content': 'How are you?', 'timestamp': (base_time + timedelta(seconds=120)).isoformat()} # 60s delay
    ]
    result = turn_taking_analyzer.analyze_conversation(messages)
    assert 59.0 <= result.avg_response_time <= 61.0

"""
Language Style Matching (LSM) Analyzer
Based on Ireland & Pennebaker (2010) research
"""
from collections import defaultdict
from ..models.schemas import LSMScore

class LSMAnalyzer:
    """
    언어 스타일 매칭 (LSM) 분석기
    """
    
    # 한국어 기능어 카테고리
    FUNCTION_WORDS = {
        'personal_pronouns': ['나', '저', '내', '제', '나는', '저는', '내가', '제가'],
        'you_pronouns': ['너', '당신', '네', '니', '너는', '너도', '너의'],
        'we_pronouns': ['우리', '우리는', '우리의', '우리가'],
        'articles': ['이', '그', '저', '그', '그거', '이거', '저거'],
        'prepositions': ['에', '에서', '로', '으로', '에게', '한테', '께'],
        'auxiliary_verbs': ['하다', '되다', '이다', '아니다', '있다', '없다'],
        'conjunctions': ['그리고', '그러나', '또는', '하지만', '그래서', '그런데'],
        'quantifiers': ['많은', '적은', '모든', '몇', '여러', '다른'],
        'negations': ['안', '못', '없다', '아니', '말다'],
    }

    def __init__(self):
        """Initialize Kiwi morphological analyzer"""
        try:
            from kiwipiepy import Kiwi
            self.kiwi = Kiwi()
        except ImportError:
            print("⚠️ kiwipiepy not installed. LSM analysis will be disabled.")
            self.kiwi = None

    def extract_function_words(self, text: str) -> dict[str, int]:
        """
        텍스트에서 기능어 추출

        Args:
            text: 분석할 텍스트

        Returns:
            dict: 카테고리별 기능어 개수
        """
        tokens = self.kiwi.tokenize(text)
        function_word_counts = {category: 0 for category in self.FUNCTION_WORDS}

        for token in tokens:
            word = token.form
            for category, words in self.FUNCTION_WORDS.items():
                if word in words:
                    function_word_counts[category] += 1

        return function_word_counts

    def calculate_lsm_score(self, text_a: str, text_b: str) -> LSMScore:
        """
        두 텍스트의 LSM 점수 계산

        Args:
            text_a: 첫 번째 사람의 텍스트
            text_b: 두 번째 사람의 텍스트

        Returns:
            LSMScore: LSM 점수 및 카테고리별 분석
        """
        # 기능어 추출
        counts_a = self.extract_function_words(text_a)
        counts_b = self.extract_function_words(text_b)

        # 총 단어 수
        total_a = sum(counts_a.values()) or 1
        total_b = sum(counts_b.values()) or 1

        # 비율 계산
        ratios_a = {k: v / total_a for k, v in counts_a.items()}
        ratios_b = {k: v / total_b for k, v in counts_b.items()}

        # 카테고리별 유사도 계산
        category_scores = {}
        for category in self.FUNCTION_WORDS.keys():
            diff = abs(ratios_a[category] - ratios_b[category])
            similarity = 1 - diff  # 차이가 적을수록 높은 점수
            category_scores[category] = max(0, min(1, similarity))

        # 전체 LSM 점수 (카테고리 평균)
        lsm_score = sum(category_scores.values()) / len(category_scores)

        return LSMScore(
            lsm_score=lsm_score,
            category_breakdown=category_scores
        )

    def analyze_conversation(self, messages: list[dict]) -> LSMScore:
        """
        대화 전체의 LSM 분석

        Args:
            messages: [{sender_id, content}, ...] 형태의 메시지 리스트

        Returns:
            LSMScore: 전체 대화의 평균 LSM 점수
        """
        # 사용자별로 텍스트 분리
        user_texts = defaultdict(list)
        for msg in messages:
            user_texts[msg['sender_id']].append(msg['content'])

        # 두 사용자 확인
        if len(user_texts) != 2:
            # 혼자 대화하는 경우 또는 3명 이상인 경우 - 기본값 반환
            return LSMScore(
                lsm_score=0.5,
                category_breakdown={cat: 0.5 for cat in self.FUNCTION_WORDS.keys()}
            )

        # 각 사용자의 전체 텍스트 합치기
        users = list(user_texts.keys())
        text_a = ' '.join(user_texts[users[0]])
        text_b = ' '.join(user_texts[users[1]])

        return self.calculate_lsm_score(text_a, text_b)

    def get_lsm_interpretation(self, lsm_score: float) -> str:
        """
        LSM 점수 해석

        Args:
            lsm_score: LSM 점수 (0~1)

        Returns:
            str: 점수에 대한 해석
        """
        if lsm_score >= 0.8:
            return "매우 높은 언어 스타일 유사도 - 관계가 매우 좋습니다!"
        elif lsm_score >= 0.7:
            return "높은 언어 스타일 유사도 - 서로 잘 맞는 편입니다."
        elif lsm_score >= 0.6:
            return "보통 수준의 언어 스타일 유사도 - 평범한 상태입니다."
        elif lsm_score >= 0.5:
            return "다소 낮은 언어 스타일 유사도 - 소통 방식에 차이가 있습니다."
        else:
            return "낮은 언어 스타일 유사도 - 대화 스타일 개선이 필요합니다."

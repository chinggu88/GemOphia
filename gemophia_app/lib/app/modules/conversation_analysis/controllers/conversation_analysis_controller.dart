import 'package:get/get.dart';

class ConversationAnalysisController extends GetxController {
  final emotionScore = 75.obs;
  final relationshipHealth = 85.obs;
  final totalConversations = 142.obs;
  final averageResponseTime = '2.5분'.obs;

  // 감정 분석 데이터
  final List<Map<String, dynamic>> emotionData = [
    {'emotion': '긍정', 'percentage': 65, 'color': 0xFF4CAF50},
    {'emotion': '중립', 'percentage': 25, 'color': 0xFFFFEB3B},
    {'emotion': '부정', 'percentage': 10, 'color': 0xFFF44336},
  ];

  // 최근 대화 키워드
  final recentKeywords = <String>[
    '데이트',
    '영화',
    '맛집',
    '주말',
    '여행',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalysisData();
  }

  void loadAnalysisData() {
    // TODO: API를 통해 실제 대화 분석 데이터 로드
  }

  void refreshData() {
    // TODO: 데이터 새로고침
    loadAnalysisData();
  }
}

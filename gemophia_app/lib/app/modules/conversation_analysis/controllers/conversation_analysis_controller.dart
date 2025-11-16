import 'package:flutter/material.dart';
import 'package:gemophia_app/app/data/models/todo_model.dart';
import 'package:gemophia_app/app/services/supabase_service.dart';
import 'package:get/get.dart';

class ConversationAnalysisController extends GetxController {
  final emotionScore = 75.obs;
  final relationshipHealth = 85.obs;
  final totalConversations = 142.obs;
  final averageResponseTime = '2.5분'.obs;

  final _minDate = DateTime(DateTime.now().year, 1, 1).obs;
  DateTime get minDate => _minDate.value;
  set minDate(DateTime value) => _minDate.value = value;

  final _maxDate = DateTime(DateTime.now().year, 12, 31).obs;
  DateTime get maxDate => _maxDate.value;
  set maxDate(DateTime value) => _maxDate.value = value;

  final _heatmap = <HeatmapItem>[].obs;
  set heatmap(List<HeatmapItem> value) => _heatmap.value = value;
  List<HeatmapItem> get heatmap => _heatmap.toList();

  final ScrollController scrollController = ScrollController();

  // 감정 분석 데이터
  final List<Map<String, dynamic>> emotionData = [
    {'emotion': '긍정', 'percentage': 65, 'color': 0xFF4CAF50},
    {'emotion': '중립', 'percentage': 25, 'color': 0xFFFFEB3B},
    {'emotion': '부정', 'percentage': 10, 'color': 0xFFF44336},
  ];

  // 최근 대화 키워드
  final recentKeywords = <String>['데이트', '영화', '맛집', '주말', '여행'].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    loadAnalysisData();
    final temptodo = await SupabaseService.to.readAll(table: 'todo');
    heatmap = temptodo.map((e) => HeatmapItem.fromJson(e)).toList();
  }

  void loadAnalysisData() {
    // TODO: API를 통해 실제 대화 분석 데이터 로드
  }

  void refreshData() {
    // TODO: 데이터 새로고침
    loadAnalysisData();
  }

  @override
  void onReady() {
    // 오늘 날짜로 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToToday();
    });
    super.onReady();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void toggleTodo(String id) {
    final index = heatmap.indexWhere((todo) => todo.id == id);
    // if (index != -1) {
    //   todos[index].isCompleted = !todos[index].isCompleted;

    // }
  }

  void deleteTodo(String id) {
    heatmap.removeWhere((todo) => todo.id == id);
  }

  void scrollToToday() {
    final now = DateTime.now();
    final daysSinceStart = now.difference(minDate).inDays;

    // 셀 크기 19 + 간격을 고려한 대략적인 계산
    // 주당 7일, 각 셀이 약 20-25픽셀 정도
    final weeksSinceStart = (daysSinceStart / 7).floor();
    final scrollOffset = weeksSinceStart * 19.0; // 주당 대략적인 너비

    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}

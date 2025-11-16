import 'package:contribution_heatmap/contribution_heatmap.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gemophia_app/app/core/values/app_colors.dart';
import 'package:get/get.dart';
import '../controllers/conversation_analysis_controller.dart';

class ConversationAnalysisView extends GetView<ConversationAnalysisController> {
  const ConversationAnalysisView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Streamlit 배경색
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 섹션
              Text(
                '대화 분석',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[900],
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 12),
              // 통계 요약 Row
              _buildStatsRow(),
              SizedBox(height: 12),
              Text(
                '이벤트 이력',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[900],
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 5),
              _buildOldHeader(),
              SizedBox(height: 12),

              // 파이 차트 카드
              _buildPieChartCard(context),
              SizedBox(height: 24),

              // 최근 키워드 카드
              _buildKeywordsCard(context),
              SizedBox(height: 24),
              // 감정 분석 카드
              _buildEmotionAnalysisCard(context),
              SizedBox(height: 24),
              Text(
                '400일 15시간',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '우리의 관계를 데이터로 확인해보세요',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32),

              // Metric 섹션
              _buildMetricsSection(context),
              SizedBox(height: 24),

              // 관계 건강도 카드
              _buildHealthScoreCard(context),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard(
            label: '오늘대화',
            value: '142',
            subtitle: '↑ 12% 증가',
            subtitleColor: const Color(0xFF21C073),
            icon: Icons.chat_bubble,
            iconColor: const Color(0xFF9D4EDD),
            backgroundColor: const Color(0xFFF3E8FF),
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            label: '감정 지수',
            value: '87%',
            subtitle: '매우 긍정적',
            subtitleColor: const Color(0xFF21C073),
            icon: Icons.sentiment_satisfied_alt,
            iconColor: const Color(0xFFFF6B9D),
            backgroundColor: const Color(0xFFFFE8F0),
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            label: '관계 점수',
            value: 'A+',
            subtitle: '상위 5%',
            subtitleColor: const Color(0xFF0068C9),
            icon: Icons.emoji_events,
            iconColor: const Color(0xFFFFC107),
            backgroundColor: const Color(0xFFFFF9E6),
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            label: '다음기념일',
            value: 'D-13',
            subtitle: '400일❤️',
            subtitleColor: const Color(0xFF0068C9),
            icon: Icons.date_range,
            iconColor: const Color(0xFFFFC107),
            backgroundColor: const Color(0xFFFFF9E6),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String subtitle,
    required Color subtitleColor,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.grey[900],
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context) {
    return Column(
      children: [
        _buildMetricCard(
          context,
          label: '총 대화 수',
          value: controller.totalConversations.value.toString(),
          icon: Icons.chat_bubble_outline,
          color: const Color(0xFF0068C9), // Streamlit blue
        ),
        SizedBox(height: 12),
        _buildMetricCard(
          context,
          label: '평균 응답 시간',
          value: controller.averageResponseTime.value,
          icon: Icons.timer_outlined,
          color: const Color(0xFFFF4B4B), // Streamlit red
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: const Color(0xFFFF4B4B), size: 22),
              SizedBox(width: 8),
              Text(
                '관계 건강도',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Center(
            child: Obx(
              () => Column(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            value: controller.relationshipHealth.value / 100,

                            backgroundColor: Colors.grey[100],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getHealthColor(
                                controller.relationshipHealth.value,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${controller.relationshipHealth.value}',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey[900],
                              ),
                            ),
                            Text(
                              '/ 100',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '매우 좋은 상태입니다!',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionAnalysisCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                color: const Color(0xFF0068C9),
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                '감정 분석',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...controller.emotionData.map(
            (emotion) => Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        emotion['emotion'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${emotion['percentage']}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[900],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: LinearProgressIndicator(
                      value: emotion['percentage'] / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[100],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(emotion['color']),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_outline,
                color: const Color(0xFF9D4EDD),
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                '대화 유형 분포',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: 35,
                    title: '35%',
                    color: const Color(0xFF9D4EDD),
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 25,
                    title: '25%',
                    color: const Color(0xFFFF6B9D),
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '20%',
                    color: const Color(0xFF0068C9),
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '20%',
                    color: const Color(0xFF21C073),
                    radius: 60,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          // 범례
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildLegendItem('일상 대화', const Color(0xFF9D4EDD)),
              _buildLegendItem('감정 공유', const Color(0xFFFF6B9D)),
              _buildLegendItem('계획 논의', const Color(0xFF0068C9)),
              _buildLegendItem('기타', const Color(0xFF21C073)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildKeywordsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tag_outlined,
                color: const Color(0xFF21C073),
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                '최근 대화 키워드',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  controller.recentKeywords.map((keyword) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F6),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: Text(
                        keyword,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOldHeader() {
    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: controller.scrollController,
        child: ContributionHeatmap(
          startWeekday: DateTime.monday,
          cellRadius: 5,
          minDate: controller.minDate,
          maxDate: controller.maxDate,
          cellSize: 19,
          splittedMonthView: false,
          showCellDate: false,
          entries: [
            ...controller.heatmap.map((todo) {
              return ContributionEntry(todo.createdAt!, todo.cnt!);
            }),
          ],
          colorScale: (value) {
            switch (value) {
              case 0:
                return Colors.grey.shade200;
              case 1:
                return AppColors.primary.withOpacity(0.5);
              case 2:
                return AppColors.primary.withOpacity(0.7);
              case 3:
                return AppColors.primary;
            }
            return Colors.grey.shade200;
          },
          showMonthLabels: true,
        ),
      );
    });
  }

  Color _getHealthColor(int score) {
    if (score >= 80) return const Color(0xFF21C073); // Streamlit green
    if (score >= 60) return const Color(0xFFFFA500);
    return const Color(0xFFFF4B4B); // Streamlit red
  }
}

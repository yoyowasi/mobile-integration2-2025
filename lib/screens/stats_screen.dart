import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../features/timer/data/session_store.dart';
import '../providers/session_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  final SessionStore _sessionStore = SessionStore();
  bool _isWeekly = true; // true: 주간, false: 오늘 시간대별

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionListProvider);

    return sessionsAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF7F8FA),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFE74D50))),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: Center(child: Text('오류 발생: $err')),
      ),
      data: (sessions) {
        // 🔥 Provider 데이터로 즉시 계산
        final weeklyData = _sessionStore.calculateWeeklyData(sessions);
        // 🔥 [수정] 일별 -> 오늘 시간대별 데이터 (0시~23시)
        final hourlyData = _sessionStore.calculateHourlyData(sessions);

        final totalStats = _sessionStore.calculateTotalStats(sessions);
        final topReasons = _sessionStore.calculateTopQuitReasons(sessions);

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              '통계',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: RefreshIndicator(
            color: const Color(0xFFE74D50),
            onRefresh: () => ref.refresh(sessionListProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 요약 카드
                _buildSummaryCards(totalStats),

                const SizedBox(height: 24),

                // 차트 토글
                _buildChartToggle(),

                const SizedBox(height: 16),

                // 차트 영역
                _buildChart(weeklyData, hourlyData),

                const SizedBox(height: 24),

                // 중단 원인 TOP 3
                _buildQuitReasons(topReasons),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> totalStats) {
    final totalMinutes = totalStats['totalMinutes'] ?? 0;
    final completedCount = totalStats['completedCount'] ?? 0;
    final completionRate = (totalStats['completionRate'] ?? 0.0) * 100;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: '총 집중 시간',
            value: '${totalMinutes}분',
            icon: Icons.timer,
            color: const Color(0xFFE74D50),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: '완료 세션',
            value: '$completedCount개',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: '완료율',
            value: '${completionRate.toStringAsFixed(0)}%',
            icon: Icons.show_chart,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isWeekly = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isWeekly ? const Color(0xFFE74D50) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '주간',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isWeekly ? Colors.white : Colors.black54,
                    fontWeight: _isWeekly ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isWeekly = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isWeekly ? const Color(0xFFE74D50) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '일별', // 텍스트 변경
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_isWeekly ? Colors.white : Colors.black54,
                    fontWeight: !_isWeekly ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 [수정] 두 번째 인자를 Map<int, double> (시간대별 데이터)로 변경
  Widget _buildChart(Map<String, double> weeklyData, Map<int, double> hourlyData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isWeekly ? '이번 주 집중 시간' : '오늘 시간대별 집중', // 타이틀 변경
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _isWeekly ? _buildWeeklyChart(weeklyData) : _buildHourlyChart(hourlyData),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(Map<String, double> weeklyData) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxValue = weeklyData.values.isEmpty
        ? 100.0
        : weeklyData.values.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue == 0 ? 60 : maxValue * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay = days[group.x.toInt()];
              return BarTooltipItem(
                '$weekDay\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '${rod.toY.round()}분',
                    style: const TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(days.length, (index) {
          final day = days[index];
          final value = weeklyData[day] ?? 0;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE74D50),
                    Color(0xFFFF8A80),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }

  // 🔥 [추가] 시간대별(0~23시) 차트 메서드
  Widget _buildHourlyChart(Map<int, double> hourlyData) {
    // 데이터가 하나도 없으면 빈 화면 표시
    if (hourlyData.values.every((v) => v == 0)) {
      return _buildEmptyState();
    }

    final maxValue = hourlyData.values.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center, // 막대 간격 균등 배치
        maxY: maxValue == 0 ? 60 : maxValue * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${group.x}시\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                    text: '${rod.toY.round()}분',
                    style: const TextStyle(color: Colors.yellowAccent),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 6, // 0, 6, 12, 18 (6시간 간격 표시)
              getTitlesWidget: (value, meta) {
                final hour = value.toInt();
                if (hour % 6 == 0 && hour <= 23) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '$hour시',
                      style: const TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        // 0시부터 23시까지 24개 막대 생성
        barGroups: List.generate(24, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: hourlyData[index] ?? 0,
                color: const Color(0xFFE74D50),
                width: 8, // 막대 개수가 많으므로 얇게 조정
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text(
            '오늘 집중 기록이 없어요',
            style: TextStyle(color: Colors.black54),
          ),
          TextButton(
            onPressed: () {
              context.go('/'); // 타이머 화면으로 이동
            },
            child: const Text(
              '지금 집중하러 가기',
              style: TextStyle(color: Color(0xFFE74D50), fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuitReasons(List<Map<String, dynamic>> topReasons) {
    if (topReasons.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '중단 기록이 없습니다',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    final reasonLabels = {
      'phone': '스마트폰',
      'tired': '피곤함',
      'hungry': '배고픔',
      'distracted': '집중력 저하',
      'urgent': '급한 일',
      'other': '기타',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주요 중단 원인',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...topReasons.map((reason) {
            final label = reasonLabels[reason['reason']] ?? '❓ 알 수 없음';
            final count = reason['count'];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74D50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count회',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE74D50),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
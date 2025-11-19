import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../features/timer/data/session_store.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final SessionStore _sessionStore = SessionStore();

  bool _isWeekly = true; // true: 주간, false: 일별
  Map<String, double> _weeklyData = {};
  Map<int, double> _dailyData = {};
  Map<String, dynamic> _totalStats = {};
  List<Map<String, dynamic>> _topReasons = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final weekly = await _sessionStore.getWeeklyData();
    final daily = await _sessionStore.getDailyData();
    final stats = await _sessionStore.getTotalStats();
    final reasons = await _sessionStore.getTopQuitReasons();

    if (!mounted) return;
    setState(() {
      _weeklyData = weekly;
      _dailyData = daily;
      _totalStats = stats;
      _topReasons = reasons;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F8FA),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFE74D50))),
      );
    }

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
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 요약 카드
            _buildSummaryCards(),

            const SizedBox(height: 24),

            // 차트 토글
            _buildChartToggle(),

            const SizedBox(height: 16),

            // 차트
            _buildChart(),

            const SizedBox(height: 24),

            // 중단 원인 TOP 3
            _buildQuitReasons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalMinutes = _totalStats['totalMinutes'] ?? 0;
    final completedCount = _totalStats['completedCount'] ?? 0;
    final completionRate = (_totalStats['completionRate'] ?? 0.0) * 100;

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
            color: Colors.black.withOpacity(0.05),
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
            color: Colors.black.withOpacity(0.05),
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
                  '일별',
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

  Widget _buildChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isWeekly ? '주간 집중 시간' : '일별 집중 시간',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _isWeekly ? _buildWeeklyChart() : _buildDailyChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxValue = _weeklyData.values.isEmpty ? 100.0 : _weeklyData.values.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        barTouchData: BarTouchData(enabled: false),
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
          final value = _weeklyData[day] ?? 0;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: const Color(0xFFE74D50),
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDailyChart() {
    if (_dailyData.isEmpty) {
      return const Center(
        child: Text(
          '데이터가 없습니다',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    final sortedEntries = _dailyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final maxValue = sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedEntries.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${sortedEntries[index].key}',
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
        barGroups: List.generate(sortedEntries.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: sortedEntries[index].value,
                color: const Color(0xFFE74D50),
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildQuitReasons() {
    if (_topReasons.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
            color: Colors.black.withOpacity(0.05),
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
          ..._topReasons.map((reason) {
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
                      color: const Color(0xFFE74D50).withOpacity(0.1),
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

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../timer/data/session_model.dart';
import '../timer/data/session_store.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final SessionStore _store = SessionStore();
  bool _isWeeklyView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('통계', style: TextStyle(color: Colors.black87)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isWeeklyView = !_isWeeklyView;
              });
            },
            icon: Icon(_isWeeklyView ? Icons.calendar_today : Icons.view_week),
            label: Text(_isWeeklyView ? '주간' : '일별'),
          ),
        ],
      ),
      body: FutureBuilder<List<SessionModel>>(
        future: _store.getWeeklySessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final sessions = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(sessions),
                const SizedBox(height: 24),
                _buildChartSection(sessions),
                const SizedBox(height: 24),
                _buildQuitReasonAnalysis(sessions),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(List<SessionModel> sessions) {
    final totalMinutes = sessions.fold<int>(
      0,
          (sum, s) => sum + (s.durationSec ~/ 60),
    );
    final completedCount = sessions.where((s) => s.completed).length;
    final completionRate = sessions.isEmpty
        ? 0.0
        : completedCount / sessions.length * 100;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '총 집중 시간',
            '${totalMinutes}분',
            Icons.timer,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '완료한 세션',
            '$completedCount개',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '완료율',
            '${completionRate.toStringAsFixed(0)}%',
            Icons.trending_up,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
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
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(List<SessionModel> sessions) {
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
            _isWeeklyView ? '주간 집중 시간' : '일별 집중 시간',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _buildBarChart(sessions),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<SessionModel> sessions) {
    // 일별 데이터 그룹화
    final Map<String, int> dailyMinutes = {};

    for (var session in sessions) {
      final dateKey = DateFormat('MM/dd').format(session.endedAt);
      dailyMinutes[dateKey] =
          (dailyMinutes[dateKey] ?? 0) + (session.durationSec ~/ 60);
    }

    // 최근 7일 데이터 생성
    final now = DateTime.now();
    final List<BarChartGroupData> barGroups = [];
    double maxValue = 60.0;

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('MM/dd').format(date);
      final minutes = (dailyMinutes[dateKey] ?? 0).toDouble();

      if (minutes > maxValue) maxValue = minutes;

      barGroups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: minutes,
              color: Colors.blue,
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = now.subtract(Duration(days: 6 - value.toInt()));
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('E').format(date).substring(0, 1),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 30,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.black12,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: false,
        ),
      ),
    );
  }

  Widget _buildQuitReasonAnalysis(List<SessionModel> sessions) {
    final quitReasons = <String, int>{};

    for (var session in sessions) {
      if (session.quitReason != null && !session.completed) {
        quitReasons[session.quitReason!] =
            (quitReasons[session.quitReason!] ?? 0) + 1;
      }
    }

    if (quitReasons.isEmpty) {
      return const SizedBox.shrink();
    }

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
            '중단 원인 분석',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...quitReasons.entries.map((entry) {
            final emoji = _getEmojiForReason(entry.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_getReasonLabel(entry.key))),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${entry.value}회',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
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

  String _getEmojiForReason(String reason) {
    switch (reason) {
      case 'phone': return '📱';
      case 'tired': return '😴';
      case 'hunger': return '🍽️';
      case 'distracted': return '🤔';
      case 'urgent': return '🚶';
      default: return '📝';
    }
  }

  String _getReasonLabel(String reason) {
    switch (reason) {
      case 'phone': return '스마트폰 사용';
      case 'tired': return '피곤함';
      case 'hunger': return '배고픔/갈증';
      case 'distracted': return '집중력 저하';
      case 'urgent': return '급한 일';
      default: return '기타';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inbox, size: 80, color: Colors.black26),
          SizedBox(height: 16),
          Text(
            '아직 기록된 세션이 없습니다',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          SizedBox(height: 8),
          Text(
            '타이머를 사용하면 통계가 표시됩니다',
            style: TextStyle(fontSize: 14, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}

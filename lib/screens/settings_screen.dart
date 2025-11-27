import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/timer/data/session_store.dart';
import '../features/timer/data/session_model.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '설정',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 타이머 설정 섹션
          const Text(
            '타이머 설정',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          _buildTimerSetting(
            context: context,
            ref: ref,
            title: '기본 타이머 시간',
            subtitle: 'Custom 모드 기본 시간',
            currentValue: settings.defaultMinutes,
            minValue: 1,
            maxValue: 60,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setDefaultMinutes(value);
            },
          ),

          const SizedBox(height: 24),

          // Auto 알고리즘 안내
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto 모드 범위',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AI가 10분 ~ 60분 범위에서\n최적 시간을 추천합니다',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 데이터 관리 섹션
          const Text(
            '데이터 관리',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // 테스트 데이터 생성 버튼
          _buildActionCard(
            title: '테스트 데이터 생성',
            subtitle: '통계 확인용 샘플 데이터 20개',
            icon: Icons.science,
            color: Colors.purple,
            onTap: () => _generateTestData(context),
          ),

          const SizedBox(height: 12),

          _buildActionCard(
            title: '설정 초기화',
            subtitle: '모든 설정을 기본값으로',
            icon: Icons.restart_alt_rounded,
            color: Colors.orange,
            onTap: () => _showResetSettingsDialog(context, ref),
          ),

          const SizedBox(height: 12),

          _buildActionCard(
            title: '세션 기록 삭제',
            subtitle: '저장된 모든 세션 데이터 삭제',
            icon: Icons.delete_forever_rounded,
            color: Colors.red,
            onTap: () => _showClearDataDialog(context),
          ),

          const SizedBox(height: 32),

          // 앱 정보
          _buildInfoCard(context),
        ],
      ),
    );
  }

  // 테스트 데이터 생성 메서드
  Future<void> _generateTestData(BuildContext context) async {
    final store = SessionStore();

    // 최근 7일간 랜덤 데이터 생성
    for (int i = 0; i < 20; i++) {
      final daysAgo = (i / 3).floor();
      final startTime = DateTime.now()
          .subtract(Duration(days: daysAgo, hours: i % 8, minutes: i % 60));

      final duration = [15, 20, 25, 30][i % 4];
      final completed = i % 3 != 0; // 66% 완료율

      await store.append(SessionModel(
        startedAt: startTime,
        endedAt: startTime.add(Duration(minutes: duration)),
        durationSec: duration * 60,
        mode: i % 2 == 0 ? 'custom' : 'auto',
        completed: completed,
        quitReason: completed ? null : ['phone', 'tired', 'hungry', 'distracted'][i % 4],
      ));
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('테스트 데이터 20개 생성 완료!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTimerSetting({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required int currentValue,
    required int minValue,
    required int maxValue,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74D50).withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$currentValue분',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE74D50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '${minValue}분',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Expanded(
                child: Slider(
                  value: currentValue.toDouble(),
                  min: minValue.toDouble(),
                  max: maxValue.toDouble(),
                  divisions: maxValue - minValue,
                  activeColor: const Color(0xFFE74D50),
                  onChanged: (value) => onChanged(value.toInt()),
                ),
              ),
              Text(
                '${maxValue}분',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.timer_rounded,
            size: 48,
            color: Color(0xFFE74D50),
          ),
          const SizedBox(height: 12),
          const Text(
            'Adaptive Pomodoro',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'v1.0.0',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'AI 기반 집중 시간 최적화 타이머',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black38,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('설정 초기화'),
        content: const Text('모든 설정을 기본값으로 되돌립니다.\n계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('설정이 초기화되었습니다'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('초기화', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('세션 기록 삭제'),
        content: const Text('저장된 모든 세션 데이터가 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await SessionStore().clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('모든 기록이 삭제되었습니다'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../features/timer/data/session_store.dart';
import '../features/timer/data/session_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final SessionStore _sessionStore = SessionStore();
  List<SessionModel> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);

    final sessions = await _sessionStore.getAll();

    if (!mounted) return;

    // [수정됨] 단순히 뒤집는 대신, 시작 시간(startedAt)을 기준으로 내림차순(최신순) 정렬합니다.
    // b.compareTo(a)를 사용하면 최신 날짜가 앞으로 옵니다.
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));

    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  Future<void> _deleteSession(SessionModel session) async {
    final allSessions = await _sessionStore.getAll();
    allSessions.removeWhere((s) =>
    s.startedAt == session.startedAt &&
        s.endedAt == session.endedAt
    );

    // SharedPreferences에 다시 저장
    // 불필요한 변수 할당을 제거하고 로직을 유지합니다.
    await _sessionStore.clear();
    for (var s in allSessions) {
      await _sessionStore.append(s);
    }

    _loadSessions();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ 세션이 삭제되었습니다'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F8FA),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE74D50)),
        ),
      );
    }

    if (_sessions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            '기록',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_rounded,
                size: 80,
                color: Colors.black26,
              ),
              const SizedBox(height: 16),
              const Text(
                '세션 기록이 없습니다',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '타이머를 시작해보세요!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '기록',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '총 ${_sessions.length}개',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFE74D50),
        onRefresh: _loadSessions,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _sessions.length,
          itemBuilder: (context, index) {
            final session = _sessions[index];
            final isFirst = index == 0;
            final isNewDay = isFirst ||
                !_isSameDay(session.startedAt, _sessions[index - 1].startedAt);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isNewDay) _buildDateHeader(session.startedAt),
                _buildSessionCard(session),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(sessionDate).inDays;

    String dateText;
    if (difference == 0) {
      dateText = '오늘';
    } else if (difference == 1) {
      dateText = '어제';
    } else {
      dateText = DateFormat('M월 d일 (E)', 'ko_KR').format(date);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        dateText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSessionCard(SessionModel session) {
    final duration = session.durationSec ~/ 60;
    final startTime = DateFormat('HH:mm').format(session.startedAt);
    final endTime = DateFormat('HH:mm').format(session.endedAt);

    final reasonLabels = {
      'phone': '📱 스마트폰',
      'tired': '😴 피곤함',
      'hungry': '🍽️ 배고픔',
      'distracted': '🤔 집중력 저하',
      'urgent': '🚶 급한 일',
      'other': '📝 기타',
    };

    return Dismissible(
      key: Key('${session.startedAt}_${session.endedAt}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('세션 삭제'),
            content: const Text('이 세션을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  '삭제',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => _deleteSession(session),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            // 상태 아이콘
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: session.completed
                    ? Colors.green.withAlpha(26)
                    : Colors.orange.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                session.completed ? Icons.check_circle : Icons.cancel,
                color: session.completed ? Colors.green : Colors.orange,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // 세션 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        session.completed ? '완료' : '중단',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: session.completed
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: session.mode == 'auto'
                              ? Colors.blue.withAlpha(26)
                              : Colors.purple.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          session.mode == 'auto' ? 'Auto' : 'Custom',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: session.mode == 'auto'
                                ? Colors.blue
                                : Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$startTime ~ $endTime',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  if (!session.completed && session.quitReason != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        reasonLabels[session.quitReason] ?? '❓ 알 수 없음',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 소요 시간
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$duration분',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE74D50),
                  ),
                ),
                const Text(
                  '집중',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
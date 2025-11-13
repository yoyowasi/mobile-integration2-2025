import 'package:shared_preferences/shared_preferences.dart';

class ToStoreService {
  // 공용 키 (타이머 세션 JSON 저장용)
  static const String _sessionsKey = 'timer_sessions_json';

  /// 임의 문자열 저장/로드/삭제 (일반 용도)
  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> loadString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// 타이머 세션 전용 JSON 저장/로드 (기존 코드 호환용)
  Future<void> saveSessionsJson(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionsKey, json);
  }

  Future<String?> loadSessionsJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionsKey);
  }

  // 설정 키
  static const String _modeKey = 'settings_mode';
  static const String _focusKey = 'settings_focus_minutes';
  static const String _breakKey = 'settings_break_minutes';
  static const String _notifyKey = 'settings_notify_enabled';

  /// 앱 시작 시 초기화 (필요 시)
  Future<void> init() async {
    // SharedPreferences.setMockInitialValues({}); // 테스트용
  }

  /// 설정값 가져오기 (없으면 기본값 반환)
  Future<String> getMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_modeKey) ?? 'auto';
  }

  Future<int> getFocusMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_focusKey) ?? 25;
  }

  Future<int> getBreakMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_breakKey) ?? 5;
  }

  Future<bool> isNotifyEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notifyKey) ?? true;
  }
}

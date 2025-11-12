// lib/core/tostore_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class ToStoreService {
  const ToStoreService();

  // ---------- primitive KV ----------
  static Future<void> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // ---------- session logs ----------
  static Future<void> appendSessionLog({
    required String mode, // 'focus' | 'break'
    required int durationSec,
    required bool completed,
    DateTime? endedAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('session_logs');
    final List<Map<String, dynamic>> logs =
    raw == null ? [] : List<Map<String, dynamic>>.from(jsonDecode(raw));

    logs.add({
      'mode': mode,
      'durationSec': durationSec,
      'completed': completed,
      'endedAt': (endedAt ?? DateTime.now()).toIso8601String(),
    });

    await prefs.setString('session_logs', jsonEncode(logs));
  }

  static Future<List<Map<String, dynamic>>> readSessionLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('session_logs');
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  static Future<void> clearSessionLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_logs');
  }

  // ---------- settings (instance methods) ----------
  Future<String> getMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('settings.mode') ?? 'auto'; // 'auto' | 'custom'
  }

  Future<void> setMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings.mode', mode);
  }

  Future<int> getFocusMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('settings.focus') ?? 25;
  }

  Future<void> setFocusMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('settings.focus', minutes);
  }

  Future<int> getBreakMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('settings.break') ?? 5;
  }

  Future<void> setBreakMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('settings.break', minutes);
  }

  Future<bool> isNotifyEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('settings.notify') ?? true;
  }

  Future<void> setNotifyEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings.notify', enabled);
  }
}

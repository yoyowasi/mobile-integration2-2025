// lib/features/timer/data/session_store.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'session_model.dart';

class SessionStore {
  static const _key = 'timer_sessions_json_v1';

  Future<List<SessionModel>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <SessionModel>[];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SessionModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> append(SessionModel s) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadAll();
    current.add(s);
    final raw = jsonEncode(current.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

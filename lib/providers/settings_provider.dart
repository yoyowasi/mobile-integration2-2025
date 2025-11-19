import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final int defaultMinutes;

  SettingsState({
    this.defaultMinutes = 25,
  });

  SettingsState copyWith({
    int? defaultMinutes,
  }) {
    return SettingsState(
      defaultMinutes: defaultMinutes ?? this.defaultMinutes,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const _keyDefaultMinutes = 'default_minutes';

  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      defaultMinutes: prefs.getInt(_keyDefaultMinutes) ?? 25,
    );
  }

  Future<void> setDefaultMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDefaultMinutes, minutes);
    state = state.copyWith(defaultMinutes: minutes);
  }

  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDefaultMinutes);
    state = SettingsState();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
      (ref) => SettingsNotifier(),
);

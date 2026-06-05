import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk menyimpan preferensi lokal per-device.
/// Singleton — satu instance selama app hidup.
class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  static const _notifKey = 'notif_enabled';
  static const _hiddenChatsPrefix = 'hidden_chats_';

  // ── Notification setting ────────────────────────────────────────────────

  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notifKey) ?? true;
  }

  Future<void> setNotificationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifKey, value);
  }

  // ── Hidden chats (per user, per device) ────────────────────────────────
  // Menyimpan daftar sessionId yang disembunyikan oleh user dari chat list.

  String _hiddenChatsKey(String userId) => '$_hiddenChatsPrefix$userId';

  Future<Set<String>> getHiddenChatIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_hiddenChatsKey(userId)) ?? []).toSet();
  }

  Future<void> hideChatSession(String userId, String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _hiddenChatsKey(userId);
    final list = prefs.getStringList(key) ?? [];
    if (!list.contains(sessionId)) {
      list.add(sessionId);
      await prefs.setStringList(key, list);
    }
  }

  Future<void> hideMultipleChatSessions(
      String userId, List<String> sessionIds) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _hiddenChatsKey(userId);
    final list = prefs.getStringList(key) ?? [];
    for (final id in sessionIds) {
      if (!list.contains(id)) list.add(id);
    }
    await prefs.setStringList(key, list);
  }

  Future<void> unhideChatSession(String userId, String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _hiddenChatsKey(userId);
    final list = prefs.getStringList(key) ?? [];
    list.remove(sessionId);
    await prefs.setStringList(key, list);
  }
}

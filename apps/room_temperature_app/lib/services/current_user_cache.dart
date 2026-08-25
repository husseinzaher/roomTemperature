import 'package:shared_preferences/shared_preferences.dart';

/// {@template current_user_cache}
/// Caches the signed-in user's id in [SharedPreferences] so a background
/// isolate (e.g. the WorkManager threshold-check task) can know *who* to
/// check without relying on Firebase Auth's session having finished
/// restoring in that fresh isolate.
/// {@endtemplate}
class CurrentUserCache {
  /// {@macro current_user_cache}
  const CurrentUserCache();

  static const _key = 'current_user_id';

  /// Persists the signed-in user's id, or clears it when [userId] is null.
  Future<void> save(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, userId);
    }
  }

  /// Reads the last-cached user id, or `null` if nobody is signed in.
  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }
}

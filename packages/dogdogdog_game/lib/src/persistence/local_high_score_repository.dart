import 'package:shared_preferences/shared_preferences.dart';

import 'high_score_repository.dart';

/// [HighScoreRepository] backed by `shared_preferences`.
class LocalHighScoreRepository implements HighScoreRepository {
  LocalHighScoreRepository({
    this.preferences,
    this.storageKey = 'dogdogdog_high_score',
  });

  /// Optional injected prefs (tests). When null, [SharedPreferences.getInstance] is used.
  final SharedPreferences? preferences;
  final String storageKey;

  Future<SharedPreferences> _prefs() async {
    return preferences ?? SharedPreferences.getInstance();
  }

  @override
  Future<int> getHighScore() async {
    final prefs = await _prefs();
    return prefs.getInt(storageKey) ?? 0;
  }

  @override
  Future<void> saveHighScore(int score) async {
    final prefs = await _prefs();
    final current = prefs.getInt(storageKey) ?? 0;
    if (score > current) {
      await prefs.setInt(storageKey, score);
    }
  }
}

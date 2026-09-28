/// Persistence boundary for high scores.
///
/// Hosts (standalone app or Tracker App embed) can swap implementations.
abstract class HighScoreRepository {
  Future<int> getHighScore();

  Future<void> saveHighScore(int score);
}

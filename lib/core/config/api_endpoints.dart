/// API 엔드포인트 상수 정의
class ApiEndpoints {
  // ==================== User & Account ====================
  static const String userProfile = '/api/user/profile';
  static const String userRegister = '/api/account/register';
  static const String userLogin = '/api/account/login';

  // ==================== Puzzles ====================
  static const String puzzles = '/api/puzzles';
  static const String puzzleById = '/api/puzzles/{id}';
  static const String randomPuzzle = '/api/puzzle/random';
  static const String dailyPuzzle = '/api/puzzle/daily';
  static const String puzzlesByDifficulty =
      '/api/puzzles/difficulty/{difficulty}';

  // ==================== Game Saves ====================
  static const String gameSave = '/api/games/save';
  static const String gameLoad = '/api/games/load';
  static const String gameDelete = '/api/games/{id}';

  // ==================== Language Packs ====================
  static const String languagePacks = '/api/language-packs';
  static const String languagePackDownload =
      '/api/language-packs/{id}/download';

  // ==================== Statistics ====================
  static const String userStats = '/api/user/stats';
  static const String gameHistory = '/api/user/game-history';
}

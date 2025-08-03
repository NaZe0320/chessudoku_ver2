import 'package:chessudoku/domain/repositories/puzzle_repository.dart';
import 'package:chessudoku/data/models/puzzle.dart';
import 'package:chessudoku/data/services/firestore_service.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

/// Firestore를 사용한 퍼즐 repository 구현체
class PuzzleRepositoryImpl implements PuzzleRepository {
  final FirestoreService _firestoreService;

  PuzzleRepositoryImpl({
    FirestoreService? firestoreService,
  }) : _firestoreService = firestoreService ?? FirestoreService();

  @override
  Future<Puzzle?> getPuzzleById(String puzzleId, Difficulty difficulty) async {
    return await _firestoreService.getPuzzleById(puzzleId, difficulty);
  }

  @override
  Future<Puzzle?> getRandomPuzzleByDifficulty(Difficulty difficulty) async {
    return await _firestoreService.getRandomPuzzleByDifficulty(difficulty);
  }

  @override
  Future<List<Puzzle>> getPuzzlesByDifficulty(Difficulty difficulty,
      {int limit = 10}) async {
    return await _firestoreService.getPuzzlesByDifficulty(difficulty,
        limit: limit);
  }
}

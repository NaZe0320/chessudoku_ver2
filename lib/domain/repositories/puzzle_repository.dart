import 'package:chessudoku/data/models/puzzle_pack.dart';

abstract class PuzzleRepository {
  Future<void> syncPuzzles(int version);
  Future<List<PuzzlePack>> getPuzzlePacks();
}

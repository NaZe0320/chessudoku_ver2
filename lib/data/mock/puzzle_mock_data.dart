import 'package:chessudoku/data/models/puzzle_pack.dart';

class PuzzleMockData {
  static final List<PuzzlePack> puzzlePacks = [
    const PuzzlePack(
      id: 'pack_01',
      name: 'Beginner Pack',
      totalPuzzles: 5,
      type: ['basics', 'opening'],
      iconAsset: 'assets/icons/pack_01.svg',
      puzzleIds: [1, 2, 3, 4, 5],
    ),
    const PuzzlePack(
      id: 'pack_02',
      name: 'Intermediate Mates',
      totalPuzzles: 3,
      type: ['checkmate', 'middlegame'],
      iconAsset: 'assets/icons/pack_02.svg',
      puzzleIds: [6, 7, 8],
    ),
    const PuzzlePack(
      id: 'pack_03',
      name: 'Advanced Tactics',
      totalPuzzles: 8,
      type: ['tactics', 'endgame'],
      iconAsset: 'assets/icons/pack_03.svg',
      puzzleIds: [9, 10, 11, 12, 13, 14, 15, 16],
    ),
    const PuzzlePack(
      id: 'pack_04',
      name: 'Opening Traps',
      totalPuzzles: 4,
      type: ['opening', 'traps'],
      iconAsset: 'assets/icons/pack_04.svg',
      puzzleIds: [17, 18, 19, 20],
    ),
    const PuzzlePack(
      id: 'pack_05',
      name: 'King and Pawn Endings',
      totalPuzzles: 6,
      type: ['endgame', 'basics'],
      iconAsset: 'assets/icons/pack_01.svg',
      puzzleIds: [21, 22, 23, 24, 25, 26],
    ),
    const PuzzlePack(
      id: 'pack_06',
      name: 'Rook Endgames',
      totalPuzzles: 5,
      type: ['endgame', 'advanced'],
      iconAsset: 'assets/icons/pack_02.svg',
      puzzleIds: [27, 28, 29, 30, 31],
    ),
    const PuzzlePack(
      id: 'pack_07',
      name: 'Defensive Puzzles',
      totalPuzzles: 7,
      type: ['defense', 'middlegame'],
      iconAsset: 'assets/icons/pack_03.svg',
      puzzleIds: [32, 33, 34, 35, 36, 37, 38],
    ),
    const PuzzlePack(
      id: 'pack_08',
      name: 'Famous Gambits',
      totalPuzzles: 4,
      type: ['opening', 'gambits'],
      iconAsset: 'assets/icons/pack_04.svg',
      puzzleIds: [39, 40, 41, 42],
    ),
    const PuzzlePack(
      id: 'pack_09',
      name: 'Checkmate in 2',
      totalPuzzles: 10,
      type: ['checkmate', 'tactics'],
      iconAsset: 'assets/icons/pack_01.svg',
      puzzleIds: [43, 44, 45, 46, 47, 48, 49, 50, 51, 52],
    ),
    const PuzzlePack(
      id: 'pack_10',
      name: 'Sicilian Defense',
      totalPuzzles: 5,
      type: ['opening', 'defense'],
      iconAsset: 'assets/icons/pack_02.svg',
      puzzleIds: [53, 54, 55, 56, 57],
    ),
    const PuzzlePack(
      id: 'pack_11',
      name: 'Fork & Pin Tactics',
      totalPuzzles: 8,
      type: ['tactics', 'basics'],
      iconAsset: 'assets/icons/pack_03.svg',
      puzzleIds: [58, 59, 60, 61, 62, 63, 64, 65],
    ),
    const PuzzlePack(
      id: 'pack_12',
      name: 'Queen vs Rook',
      totalPuzzles: 3,
      type: ['endgame', 'advanced'],
      iconAsset: 'assets/icons/pack_04.svg',
      puzzleIds: [66, 67, 68],
    ),
    const PuzzlePack(
      id: 'pack_13',
      name: 'Attacking the King',
      totalPuzzles: 6,
      type: ['middlegame', 'tactics'],
      iconAsset: 'assets/icons/pack_01.svg',
      puzzleIds: [69, 70, 71, 72, 73, 74],
    ),
    const PuzzlePack(
      id: 'pack_14',
      name: 'Positional Sacrifices',
      totalPuzzles: 4,
      type: ['middlegame', 'advanced'],
      iconAsset: 'assets/icons/pack_02.svg',
      puzzleIds: [75, 76, 77, 78],
    ),
    const PuzzlePack(
      id: 'pack_15',
      name: 'Daily Puzzle Warmup',
      totalPuzzles: 7,
      type: ['basics', 'daily'],
      iconAsset: 'assets/icons/pack_03.svg',
      puzzleIds: [79, 80, 81, 82, 83, 84, 85],
    ),
    const PuzzlePack(
      id: 'pack_16',
      name: 'Discovered Checks',
      totalPuzzles: 5,
      type: ['tactics', 'checkmate'],
      iconAsset: 'assets/icons/pack_04.svg',
      puzzleIds: [86, 87, 88, 89, 90],
    ),
    const PuzzlePack(
      id: 'pack_17',
      name: 'Minor Piece Endings',
      totalPuzzles: 6,
      type: ['endgame', 'basics'],
      iconAsset: 'assets/icons/pack_01.svg',
      puzzleIds: [91, 92, 93, 94, 95, 96],
    ),
    const PuzzlePack(
      id: 'pack_18',
      name: 'Ruy Lopez Opening',
      totalPuzzles: 4,
      type: ['opening', 'basics'],
      iconAsset: 'assets/icons/pack_02.svg',
      puzzleIds: [97, 98, 99, 100],
    ),
    const PuzzlePack(
      id: 'pack_19',
      name: 'Expert Level Puzzles',
      totalPuzzles: 5,
      type: ['advanced', 'tactics'],
      iconAsset: 'assets/icons/pack_03.svg',
      puzzleIds: [101, 102, 103, 104, 105],
    ),
    const PuzzlePack(
      id: 'pack_20',
      name: 'Fun Puzzles',
      totalPuzzles: 8,
      type: ['daily', 'basics'],
      iconAsset: 'assets/icons/pack_04.svg',
      puzzleIds: [106, 107, 108, 109, 110, 111, 112, 113],
    ),
  ];

  static Future<Map<String, dynamic>> getPuzzleDataByVersion(
      int version) async {
    // In a real scenario, you'd filter data based on the version.
    // Here, we'll just return all of it if the version is new.
    await Future.delayed(const Duration(milliseconds: 700));
    return {
      'version': version, // The new version number
      'packs': puzzlePacks.map((p) => p.toMap()).toList(),
    };
  }
}

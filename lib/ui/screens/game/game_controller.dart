import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessudoku/core/di/provider_setup.dart';
import 'package:chessudoku/domain/intents/game_intent.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:uuid/uuid.dart';

/// 게임 컨트롤러 - 게임 로직을 관리하는 고수준 컨트롤러
class GameController {
  final Ref ref;
  static const _uuid = Uuid();

  GameController(this.ref);

  /// 새 게임 시작
  void startNewGame({
    Difficulty difficulty = Difficulty.easy,
    int boardSize = 9,
  }) {
    final gameId = _uuid.v4();
    final initialBoard = _generateInitialBoard(boardSize, difficulty);

    final intent = StartGameIntent(
      gameId: gameId,
      initialBoard: initialBoard,
      difficulty: difficulty,
    );

    ref.read(gameNotifierProvider.notifier).handleIntent(intent);
  }

  /// 셀 선택
  void selectCell(int row, int col) {
    final intent = SelectCellIntent(row, col);
    ref.read(gameNotifierProvider.notifier).handleIntent(intent);
  }

  /// 숫자 입력
  void inputNumber(int number) {
    final intent = InputNumberIntent(number);
    ref.read(gameNotifierProvider.notifier).handleIntent(intent);
  }

  /// 셀 지우기
  void clearCell() {
    final intent = ClearCellIntent();
    ref.read(gameNotifierProvider.notifier).handleIntent(intent);
  }

  /// 노트 토글
  void toggleNote(int number) {
    final intent = ToggleNoteIntent(number);
    ref.read(gameNotifierProvider.notifier).handleIntent(intent);
  }

  /// 게임 일시정지
  void pauseGame() {
    final intent = PauseGameIntent();
    ref.read(gameNotifierProvider.notifier).handleIntent(intent);
  }

  /// 게임 재개
  void resumeGame() {
    final intent = ResumeGameIntent();
    ref.read(gameNotifierProvider.notifier).handleIntent(intent);
  }

  /// 게임 완료 확인
  void checkGameCompletion() {
    final intent = CheckGameCompletionIntent();
    ref.read(gameNotifierProvider.notifier).handleIntent(intent);
  }

  /// 초기 보드 생성 (임시 구현)
  List<List<CellContent>> _generateInitialBoard(
      int size, Difficulty difficulty) {
    // 실제로는 더 복잡한 스도쿠 생성 알고리즘을 사용해야 함
    final board = List.generate(
      size,
      (i) => List.generate(
        size,
        (j) => const CellContent(),
      ),
    );

    // 난이도에 따라 일부 셀에 초기값 설정 (예시)
    final initialCellsCount = _getInitialCellsCount(difficulty, size);
    var placedCells = 0;

    for (int i = 0; i < size && placedCells < initialCellsCount; i++) {
      for (int j = 0; j < size && placedCells < initialCellsCount; j++) {
        if ((i + j) % 3 == 0) {
          // 간단한 패턴으로 초기값 배치
          final number = ((i * size + j) % 9) + 1;
          board[i][j] = CellContent(
            number: number,
            isInitial: true,
          );
          placedCells++;
        }
      }
    }

    return board;
  }

  /// 난이도별 초기 셀 개수
  int _getInitialCellsCount(Difficulty difficulty, int boardSize) {
    final totalCells = boardSize * boardSize;

    switch (difficulty) {
      case Difficulty.easy:
        return (totalCells * 0.6).round(); // 60% 채움
      case Difficulty.medium:
        return (totalCells * 0.4).round(); // 40% 채움
      case Difficulty.hard:
        return (totalCells * 0.3).round(); // 30% 채움
      case Difficulty.expert:
        return (totalCells * 0.2).round(); // 20% 채움
    }
  }
}

/// GameController Provider
final gameControllerProvider = Provider<GameController>(
  (ref) => GameController(ref),
);

/// 타이머 Provider (게임 시간 추적)
final gameTimerProvider = StreamProvider<Duration>((ref) async* {
  final gameState = ref.watch(gameNotifierProvider);

  if (gameState.isPaused || gameState.isCompleted) {
    yield gameState.elapsedTime;
    return;
  }

  var currentTime = gameState.elapsedTime;

  while (!gameState.isPaused && !gameState.isCompleted) {
    await Future.delayed(const Duration(seconds: 1));
    currentTime += const Duration(seconds: 1);

    // 상태가 변경되었는지 확인
    final newGameState = ref.read(gameNotifierProvider);
    if (newGameState.isPaused || newGameState.isCompleted) {
      break;
    }

    // 시간 업데이트
    ref.read(gameNotifierProvider.notifier).updateElapsedTime(currentTime);
    yield currentTime;
  }
});

/// 게임 힌트 Provider (선택된 셀에 대한 힌트)
final gameHintProvider = Provider<List<int>?>((ref) {
  final gameState = ref.watch(gameNotifierProvider);

  if (gameState.selectedRow == null || gameState.selectedCol == null) {
    return null;
  }

  final selectedCell =
      gameState.board[gameState.selectedRow!][gameState.selectedCol!];

  if (selectedCell.hasNumber) {
    return null; // 이미 숫자가 있으면 힌트 없음
  }

  // 간단한 힌트 로직 (실제로는 더 복잡한 알고리즘 필요)
  final possibleNumbers = <int>[];

  for (int num = 1; num <= 9; num++) {
    if (_isValidMove(
        gameState.board, gameState.selectedRow!, gameState.selectedCol!, num)) {
      possibleNumbers.add(num);
    }
  }

  return possibleNumbers;
});

/// 유효한 이동인지 검사하는 함수
bool _isValidMove(List<List<CellContent>> board, int row, int col, int number) {
  // 행 검사
  for (int j = 0; j < board.length; j++) {
    if (j != col && board[row][j].number == number) {
      return false;
    }
  }

  // 열 검사
  for (int i = 0; i < board.length; i++) {
    if (i != row && board[i][col].number == number) {
      return false;
    }
  }

  // 3x3 박스 검사 (9x9 보드인 경우)
  if (board.length == 9) {
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;

    for (int i = boxRow; i < boxRow + 3; i++) {
      for (int j = boxCol; j < boxCol + 3; j++) {
        if ((i != row || j != col) && board[i][j].number == number) {
          return false;
        }
      }
    }
  }

  return true;
}

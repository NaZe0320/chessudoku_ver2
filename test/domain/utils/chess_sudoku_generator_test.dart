import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/utils/chess_sudoku_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'dart:math';
import 'chess_sudoku_solver.dart'; // ChessSudokuSolver 임포트

void main() {
  test('generateBoard 결과 출력', () {
    final generator = ChessSudokuGenerator();

    // 시간 측정 시작
    final stopwatch = Stopwatch()..start();

    final board = generator.generateBoard(Difficulty.hard);

    // 시간 측정 종료
    stopwatch.stop();

    print('=========== 체스도쿠 생성 결과 ===========');

    // 보드의 각 셀 내용을 자세히 출력
    for (int i = 0; i < board.length; i++) {
      String rowStr = '';
      for (int j = 0; j < board[i].length; j++) {
        final cell = board[i][j];
        if (cell.hasChessPiece) {
          final pieceType = cell.chessPiece.toString().split('.').last;
          // 기물 이름의 첫 글자만 사용
          String pieceSymbol = '';
          switch (pieceType) {
            case 'king':
              pieceSymbol = 'K';
              break;
            case 'queen':
              pieceSymbol = 'Q';
              break;
            case 'bishop':
              pieceSymbol = 'B';
              break;
            case 'knight':
              pieceSymbol = 'N';
              break;
            case 'rook':
              pieceSymbol = 'R';
              break;
            default:
              pieceSymbol = '?';
          }
          rowStr += '[$pieceSymbol]';
        } else if (cell.hasNumber) {
          rowStr += '[${cell.number}]';
        } else {
          rowStr += '[ ]';
        }
      }
      print('$i: $rowStr');
    }
    // 초기 힌트 숫자 개수 계산
    int initialHints = 0;
    int chessPieces = 0;
    for (final row in board) {
      for (final cell in row) {
        if (cell.hasNumber && cell.isInitial) {
          initialHints++;
        }
        if (cell.hasChessPiece) {
          chessPieces++;
        }
      }
    }

    // 결과 요약 출력
    print('\n=========== 생성 결과 요약 ===========');
    print('체스 기물 개수: $chessPieces');
    print('초기 힌트 숫자: $initialHints개');
    print('빈 칸(풀이 대상): ${81 - initialHints - chessPieces}개');
    print('생성 소요 시간: ${stopwatch.elapsedMilliseconds}ms');
  });

  test('체스도쿠 퍼즐 풀이', () async {
    final generator = ChessSudokuGenerator();

    // 퍼즐 생성 시간 측정 시작
    final generationStopwatch = Stopwatch()..start();

    print('체스도쿠 생성 중...');
    final puzzleBoard = await generator.generatePuzzle(Difficulty.hard);

    // 퍼즐 생성 시간 측정 종료
    generationStopwatch.stop();

    // 초기 힌트 숫자 개수 계산
    int initialHints = 0;
    int chessPieces = 0;
    for (final row in puzzleBoard) {
      for (final cell in row) {
        if (cell.hasNumber && cell.isInitial) {
          initialHints++;
        }
        if (cell.hasChessPiece) {
          chessPieces++;
        }
      }
    }

    // 결과 요약 출력
    print('\n=========== 생성 결과 요약 ===========');
    print('체스 기물 개수: $chessPieces');
    print('초기 힌트 숫자: $initialHints개');
    print('빈 칸(풀이 대상): ${81 - initialHints - chessPieces}개');
    print('퍼즐 생성 완료! 생성 시간: ${generationStopwatch.elapsedMilliseconds}ms');
    print('\n=========== 원본 퍼즐 보드 ===========');
    _printBoard(puzzleBoard);

    // 10번 풀이 반복을 위한 설정
    const int solveAttempts = 100;
    final List<List<List<CellContent>>> successfulBoards = []; // 성공한 보드만 저장
    final List<int> successTimes = []; // 성공한 경우의 소요 시간
    final List<int> successAttemptCounts = []; // 성공한 경우의 시도 횟수
    int successCount = 0;
    int failCount = 0;

    print('\n=========== 퍼즐 풀이 100회 반복 (랜덤 순서 사용) ===========');

    for (int i = 0; i < solveAttempts; i++) {
      print('\n[$i번째 풀이 시작]');

      // 퍼즐 복사본 생성 (원본 보존)
      final solutionBoard = _cloneBoard(puzzleBoard);

      // 풀이 시간 측정 시작
      final solvingStopwatch = Stopwatch()..start();

      // 휴리스틱 풀이 알고리즘 적용 - 각 인스턴스마다 다른 랜덤 시드 사용
      final solver = ChessSudokuSolver(solutionBoard,
          randomSeed: DateTime.now().millisecondsSinceEpoch + i,
          useRandomOrder: true // 랜덤 순서 사용 활성화
          );
      final bool solved = solver.solve();

      // 풀이 시간 측정 종료
      solvingStopwatch.stop();

      // 간략한 결과 출력
      print(
          '$i번째 풀이 결과: ${solved ? "성공" : "실패"} / ${solvingStopwatch.elapsedMilliseconds}ms / ${solver.attempts}회"}');
      // 성공한 경우만 저장
      if (solved) {
        successCount++;
        successfulBoards.add(_cloneBoard(solutionBoard));
        successTimes.add(solvingStopwatch.elapsedMilliseconds);
        successAttemptCounts.add(solver.attempts);
      } else {
        failCount++;
        print('$i번째 풀이 실패 원인: ${solver.analyzeFailure()}');
      }
    }

    // 결과 분석 및 요약
    print('\n=========== 10회 풀이 결과 요약 ===========');
    print('성공 횟수: $successCount / $solveAttempts');
    print('실패 횟수: $failCount / $solveAttempts');

    if (successCount > 0) {
      final avgSuccessTime =
          successTimes.fold(0, (sum, time) => sum + time) / successCount;
      print('평균 성공 소요 시간: ${avgSuccessTime.toStringAsFixed(2)}ms');

      final avgAttempts =
          successAttemptCounts.fold(0, (sum, count) => sum + count) /
              successCount;
      print('평균 성공 시도 횟수: ${avgAttempts.toStringAsFixed(2)}회');
    }

    // 성공한 보드들 간의 일관성 검사 (성공한 보드만 비교)
    if (successCount >= 2) {
      print('\n=========== 풀이 결과 일관성 검사 (성공한 경우만) ===========');

      // 서로 다른 해를 저장할 리스트
      List<List<List<CellContent>>> uniqueSolutions = [successfulBoards[0]];

      // 첫 번째 이후의 모든 해를 비교하여 새로운 해 찾기
      for (int i = 1; i < successfulBoards.length; i++) {
        bool isNewSolution = true;
        for (final existingSolution in uniqueSolutions) {
          if (_boardsEqual(existingSolution, successfulBoards[i])) {
            isNewSolution = false;
            break;
          }
        }
        if (isNewSolution) {
          uniqueSolutions.add(successfulBoards[i]);
        }
      }

      if (uniqueSolutions.length == 1) {
        print('모든 성공한 풀이 결과가 동일합니다 => 유일해로 판단됩니다.');
      } else {
        print(
            '성공한 풀이 결과들이 서로 다릅니다 => ${uniqueSolutions.length}개의 서로 다른 해가 발견되었습니다!');
        print('차이점 분석:');

        // 첫 번째 해를 기준으로 다른 해들과 비교
        final baseBoard = uniqueSolutions[0];
        for (int i = 1; i < uniqueSolutions.length; i++) {
          final diffBoard = uniqueSolutions[i];
          final diffCount = _countBoardDifferences(baseBoard, diffBoard);

          print('\n$i번째 해와의 차이:');
          print('기준 해와 $i번째 해의 차이: $diffCount개 셀');
        }
      }
    } else if (successCount == 1) {
      print('\n단 한 번만 성공했으므로 유일해 여부를 확정할 수 없습니다.');
    } else {
      print('\n모든 시도가 실패했으므로 풀이 불가능한 퍼즐입니다.');
    }

    // 첫 번째 성공한 보드 결과 출력
    if (successCount > 0) {
      print('\n=========== 첫 번째 성공 풀이 결과 보드 ===========');
      _printBoard(successfulBoards[0]);

      // 풀이 검증
      final firstSuccessSolver = ChessSudokuSolver(successfulBoards[0]);
      bool isValid = firstSuccessSolver.validateSolution();
      print('풀이 유효성: ${isValid ? "유효함" : "유효하지 않음"}');

      expect(isValid, true);
    } else if (failCount > 0) {
      // 모든 시도가 실패한 경우 원인 분석
      print('\n=========== 모든 풀이 실패 - 원인 분석 필요 ===========');
      print('체스도쿠 퍼즐이 해결 불가능하거나 알고리즘의 한계로 해결하지 못했습니다.');
    }
  });
}

/// 보드 복제 함수
List<List<CellContent>> _cloneBoard(List<List<CellContent>> board) {
  return List.generate(
    board.length,
    (i) => List.generate(
      board[i].length,
      (j) => board[i][j].copyWith(),
    ),
  );
}

/// 보드 출력 함수
void _printBoard(List<List<CellContent>> board) {
  for (int i = 0; i < board.length; i++) {
    String rowStr = '';
    for (int j = 0; j < board[i].length; j++) {
      final cell = board[i][j];
      if (cell.hasChessPiece) {
        final pieceType = cell.chessPiece.toString().split('.').last;
        String pieceSymbol = '';
        switch (pieceType) {
          case 'king':
            pieceSymbol = 'K';
            break;
          case 'queen':
            pieceSymbol = 'Q';
            break;
          case 'bishop':
            pieceSymbol = 'B';
            break;
          case 'knight':
            pieceSymbol = 'N';
            break;
          case 'rook':
            pieceSymbol = 'R';
            break;
          default:
            pieceSymbol = '?';
        }
        rowStr += '[$pieceSymbol]';
      } else if (cell.hasNumber) {
        rowStr += '[${cell.number}]';
      } else {
        rowStr += '[ ]';
      }
    }
    print('$i: $rowStr');
  }
}

// 풀이 실패 분석용 헬퍼 함수들
List<int> _getRowNumbers(List<List<CellContent>> board, int row) {
  final numbers = <int>[];

  for (int j = 0; j < 9; j++) {
    if (board[row][j].hasNumber) {
      numbers.add(board[row][j].number!);
    }
  }

  return numbers;
}

List<int> _getColNumbers(List<List<CellContent>> board, int col) {
  final numbers = <int>[];

  for (int i = 0; i < 9; i++) {
    if (board[i][col].hasNumber) {
      numbers.add(board[i][col].number!);
    }
  }

  return numbers;
}

List<int> _getBoxNumbers(List<List<CellContent>> board, int row, int col) {
  final numbers = <int>[];
  final boxRow = (row ~/ 3) * 3;
  final boxCol = (col ~/ 3) * 3;

  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      if (board[boxRow + i][boxCol + j].hasNumber) {
        numbers.add(board[boxRow + i][boxCol + j].number!);
      }
    }
  }

  return numbers;
}

// 두 보드가 완전히 동일한지 확인하는 함수
bool _boardsEqual(
    List<List<CellContent>> board1, List<List<CellContent>> board2) {
  if (board1.length != board2.length) return false;

  for (int i = 0; i < board1.length; i++) {
    if (board1[i].length != board2[i].length) return false;

    for (int j = 0; j < board1[i].length; j++) {
      if (!_cellsEqual(board1[i][j], board2[i][j])) {
        return false;
      }
    }
  }

  return true;
}

// 두 셀이 완전히 동일한지 확인하는 함수
bool _cellsEqual(CellContent cell1, CellContent cell2) {
  // 체스 기물 확인
  if (cell1.hasChessPiece != cell2.hasChessPiece) return false;
  if (cell1.hasChessPiece &&
      cell2.hasChessPiece &&
      cell1.chessPiece != cell2.chessPiece) return false;

  // 숫자 확인
  if (cell1.hasNumber != cell2.hasNumber) return false;
  if (cell1.hasNumber && cell2.hasNumber && cell1.number != cell2.number)
    return false;

  return true;
}

// 셀 내용을 문자열로 변환
String _cellToString(CellContent cell) {
  if (cell.hasChessPiece) {
    return cell.chessPiece.toString().split('.').last;
  } else if (cell.hasNumber) {
    return '${cell.number}';
  } else {
    return '빈칸';
  }
}

// 보드 간 차이 개수 계산
int _countBoardDifferences(
    List<List<CellContent>> board1, List<List<CellContent>> board2) {
  int diffCount = 0;

  for (int i = 0; i < board1.length; i++) {
    for (int j = 0; j < board1[i].length; j++) {
      if (!_cellsEqual(board1[i][j], board2[i][j])) {
        diffCount++;
      }
    }
  }

  return diffCount;
}

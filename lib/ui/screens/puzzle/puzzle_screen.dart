import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzleScreen extends ConsumerStatefulWidget {
  const PuzzleScreen({super.key});

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen> {
  @override
  void initState() {
    super.initState();

    // 화면이 처음 열릴 때 게임 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(puzzleIntentProvider).initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final puzzleState = ref.watch(puzzleProvider);
    final intent = ref.read(puzzleIntentProvider);
    final screenSize = MediaQuery.of(context).size;
    final boardSize = puzzleState.boardSize;

    // 화면에 맞게 보드 크기 조정
    final cellSize = (screenSize.width * 0.9) / boardSize;

    return Scaffold(
      appBar: AppBar(
        title: const Text('체스도쿠'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 타이머 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.timer, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    puzzleState.formattedTime,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // 현재 난이도 표시
          Text(
            '현재 난이도: ${puzzleState.difficulty.label}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          // 게임 완료 메시지
          if (puzzleState.isCompleted)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '축하합니다! 퍼즐을 완료했습니다!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),

          const SizedBox(height: 20),

          // 기물 범례 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ChessPiece.values.map((piece) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Tooltip(
                    message: piece.toString().split('.').last,
                    child: Text(
                      intent.getChessPieceSymbol(piece),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 퍼즐 보드
          Expanded(
            child: Center(
              child: SizedBox(
                width: screenSize.width * 0.9,
                height: screenSize.width * 0.9,
                child: puzzleState.board.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: boardSize,
                        ),
                        itemCount: boardSize * boardSize,
                        itemBuilder: (context, index) {
                          final row = index ~/ boardSize;
                          final col = index % boardSize;

                          if (row >= puzzleState.board.length ||
                              col >= puzzleState.board[row].length) {
                            return Container(color: Colors.white);
                          }

                          final cell = puzzleState.board[row][col];
                          final isSelected = puzzleState.selectedRow == row &&
                              puzzleState.selectedCol == col;

                          // 3x3 박스 경계 처리
                          final isRightBorder =
                              (col + 1) % 3 == 0 && col < boardSize - 1;
                          final isBottomBorder =
                              (row + 1) % 3 == 0 && row < boardSize - 1;

                          // 셀 배경색 결정
                          Color cellColor;
                          if (isSelected) {
                            cellColor = Colors.blue.shade200;
                          } else if (cell.isInitial) {
                            cellColor = cell.hasChessPiece
                                ? Colors.yellow.shade100
                                : Colors.grey.shade200;
                          } else {
                            cellColor = Colors.white;
                          }

                          return GestureDetector(
                            onTap: () => intent.selectCell(row, col),
                            child: Container(
                              decoration: BoxDecoration(
                                color: cellColor,
                                border: Border(
                                  right: BorderSide(
                                    width: isRightBorder ? 2 : 1,
                                    color: Colors.black,
                                  ),
                                  bottom: BorderSide(
                                    width: isBottomBorder ? 2 : 1,
                                    color: Colors.black,
                                  ),
                                  top: BorderSide(
                                    width: row == 0 ? 2 : 1,
                                    color: Colors.black,
                                  ),
                                  left: BorderSide(
                                    width: col == 0 ? 2 : 1,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: cell.hasChessPiece
                                  ? Text(
                                      intent.getChessPieceSymbol(
                                          cell.chessPiece!),
                                      style: TextStyle(
                                        fontSize: cellSize * 0.5,
                                        color: Colors.black,
                                      ),
                                    )
                                  : Text(
                                      cell.number?.toString() ?? '',
                                      style: TextStyle(
                                        fontSize: cellSize * 0.5,
                                        fontWeight: cell.isInitial
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: cell.isInitial
                                            ? Colors.black
                                            : Colors.blue,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),

          // 숫자 키패드
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              children: List.generate(9, (index) {
                return ElevatedButton(
                  onPressed: () => intent.enterNumber(index + 1),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    minimumSize: const Size(50, 50),
                  ),
                  child: Text('${index + 1}'),
                );
              })
                ..add(
                  ElevatedButton(
                    onPressed: () => intent.clearValue(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      minimumSize: const Size(50, 50),
                      backgroundColor: Colors.red.shade100,
                    ),
                    child: const Icon(Icons.clear),
                  ),
                ),
            ),
          ),

          // 난이도 선택 및 게임 제어 버튼
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<Difficulty>(
                  value: puzzleState.difficulty,
                  items: Difficulty.values.map((difficulty) {
                    return DropdownMenuItem<Difficulty>(
                      value: difficulty,
                      child: Text(difficulty.label),
                    );
                  }).toList(),
                  onChanged: (Difficulty? newValue) {
                    if (newValue != null) {
                      intent.changeDifficulty(newValue);
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: () => intent.initializeGame(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('새 게임'),
                ),
                ElevatedButton(
                  onPressed: () => intent.restartGame(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('재시작'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

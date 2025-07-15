import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessudoku/core/di/provider_setup.dart';
import 'package:chessudoku/domain/intents/game_intent.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final gameNotifier = ref.read(gameNotifierProvider.notifier);
    final gameStats = ref.watch(gameStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('체스도쿠 - ${gameState.difficulty.label}'),
        actions: [
          IconButton(
            icon: Icon(gameState.isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () {
              final intent =
                  gameState.isPaused ? ResumeGameIntent() : PauseGameIntent();
              gameNotifier.handleIntent(intent);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 게임 정보
            _GameInfoCard(
              elapsedTime: gameState.elapsedTime,
              completionPercentage: gameStats.completionPercentage,
              isCompleted: gameState.isCompleted,
              isPaused: gameState.isPaused,
            ),

            const SizedBox(height: 16),

            // 게임 보드
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: _GameBoard(
                    board: gameState.board,
                    selectedRow: gameState.selectedRow,
                    selectedCol: gameState.selectedCol,
                    onCellTap: (row, col) {
                      gameNotifier.handleIntent(SelectCellIntent(row, col));
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 컨트롤 패널
            _ControlPanel(
              onNumberInput: (number) {
                gameNotifier.handleIntent(InputNumberIntent(number));
              },
              onClearCell: () {
                gameNotifier.handleIntent(ClearCellIntent());
              },
              onToggleNote: (number) {
                gameNotifier.handleIntent(ToggleNoteIntent(number));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GameInfoCard extends StatelessWidget {
  final Duration elapsedTime;
  final double completionPercentage;
  final bool isCompleted;
  final bool isPaused;

  const _GameInfoCard({
    required this.elapsedTime,
    required this.completionPercentage,
    required this.isCompleted,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text('시간'),
                Text(
                  _formatDuration(elapsedTime),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            Column(
              children: [
                const Text('진행률'),
                Text(
                  '${completionPercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            if (isCompleted)
              const Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 32),
                  Text('완료!'),
                ],
              ),
            if (isPaused)
              const Column(
                children: [
                  Icon(Icons.pause_circle, color: Colors.orange, size: 32),
                  Text('일시정지'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _GameBoard extends StatelessWidget {
  final List<List<CellContent>> board;
  final int? selectedRow;
  final int? selectedCol;
  final Function(int row, int col) onCellTap;

  const _GameBoard({
    required this.board,
    required this.selectedRow,
    required this.selectedCol,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = board.length;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: size,
        ),
        itemCount: size * size,
        itemBuilder: (context, index) {
          final row = index ~/ size;
          final col = index % size;
          final cell = board[row][col];
          final isSelected = selectedRow == row && selectedCol == col;

          return _GameCell(
            content: cell,
            isSelected: isSelected,
            onTap: () => onCellTap(row, col),
          );
        },
      ),
    );
  }
}

class _GameCell extends StatelessWidget {
  final CellContent content;
  final bool isSelected;
  final VoidCallback onTap;

  const _GameCell({
    required this.content,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.3)
              : content.isInitial
                  ? Colors.grey.withOpacity(0.1)
                  : Colors.white,
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: content.hasNumber
              ? Text(
                  content.number.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        content.isInitial ? FontWeight.bold : FontWeight.normal,
                    color: content.isInitial ? Colors.black : Colors.blue,
                  ),
                )
              : content.hasNotes
                  ? _buildNotesWidget()
                  : null,
        ),
      ),
    );
  }

  Widget _buildNotesWidget() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        final number = index + 1;
        final hasNote = content.hasNote(number);

        return Center(
          child: hasNote
              ? Text(
                  number.toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                )
              : null,
        );
      },
    );
  }
}

class _ControlPanel extends StatefulWidget {
  final Function(int) onNumberInput;
  final VoidCallback onClearCell;
  final Function(int) onToggleNote;

  const _ControlPanel({
    required this.onNumberInput,
    required this.onClearCell,
    required this.onToggleNote,
  });

  @override
  State<_ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<_ControlPanel> {
  bool isNoteMode = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 모드 선택
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: const Text('숫자 입력'),
              selected: !isNoteMode,
              onSelected: (selected) {
                if (selected) setState(() => isNoteMode = false);
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('노트 모드'),
              selected: isNoteMode,
              onSelected: (selected) {
                if (selected) setState(() => isNoteMode = true);
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 숫자 버튼들
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 10, // 1-9 + 지우기
          itemBuilder: (context, index) {
            if (index == 9) {
              // 지우기 버튼
              return ElevatedButton(
                onPressed: widget.onClearCell,
                child: const Icon(Icons.clear),
              );
            } else {
              final number = index + 1;
              return ElevatedButton(
                onPressed: () {
                  if (isNoteMode) {
                    widget.onToggleNote(number);
                  } else {
                    widget.onNumberInput(number);
                  }
                },
                child: Text(number.toString()),
              );
            }
          },
        ),
      ],
    );
  }
}

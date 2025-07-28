import 'package:flutter/material.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';

class SudokuCell extends StatelessWidget {
  final int row;
  final int col;
  final CellContent? cellContent;
  final bool isSelected;
  final bool isHighlighted;
  final bool hasError;
  final VoidCallback onTap;

  const SudokuCell({
    super.key,
    required this.row,
    required this.col,
    this.cellContent,
    required this.isSelected,
    this.isHighlighted = false,
    this.hasError = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final value = cellContent?.number;
    final chessPiece = cellContent?.chessPiece;
    final isInitial = cellContent?.isInitial ?? false;
    final hasNotes = cellContent?.hasNotes ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getCellColor(),
          border: Border(
            top: BorderSide(
              color: _shouldShowThickBorder(row, true)
                  ? AppColors.neutral400.withValues(alpha: 0.8)
                  : AppColors.neutral400.withValues(alpha: 0.6),
              width: _shouldShowThickBorder(row, true) ? 1.0 : 0.5,
            ),
            bottom: BorderSide(
              color: _shouldShowThickBorder(row + 1, true)
                  ? AppColors.neutral400.withValues(alpha: 0.8)
                  : AppColors.neutral400.withValues(alpha: 0.6),
              width: _shouldShowThickBorder(row + 1, true) ? 1.0 : 0.5,
            ),
            left: BorderSide(
              color: _shouldShowThickBorder(col, false)
                  ? AppColors.neutral400.withValues(alpha: 0.8)
                  : AppColors.neutral400.withValues(alpha: 0.6),
              width: _shouldShowThickBorder(col, false) ? 1.0 : 0.5,
            ),
            right: BorderSide(
              color: _shouldShowThickBorder(col + 1, false)
                  ? AppColors.neutral400.withValues(alpha: 0.8)
                  : AppColors.neutral400.withValues(alpha: 0.6),
              width: _shouldShowThickBorder(col + 1, false) ? 1.0 : 0.5,
            ),
          ),
        ),
        child: Center(
          child: _buildCellContent(value, chessPiece, isInitial, hasNotes),
        ),
      ),
    );
  }

  Widget? _buildCellContent(
      int? value, ChessPiece? chessPiece, bool isInitial, bool hasNotes) {
    // 체스 기물이 있는 경우 - 체스 기물만 표시 (숫자는 무시)
    if (chessPiece != null) {
      return Text(
        _getChessPieceSymbol(chessPiece),
        style: const TextStyle(
          fontSize: 24,
          color: AppColors.onSurface,
        ),
      );
    }

    // 숫자만 있는 경우
    if (value != null) {
      return Text(
        value.toString(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: isInitial
              ? FontWeight.w400
              : FontWeight.w600, // 초기값은 얇게, 입력값은 조금 두껍게
          color: _getNumberColor(isInitial),
        ),
      );
    }

    // 메모가 있는 경우
    if (hasNotes && cellContent != null) {
      return _buildNotesGrid(cellContent!.notes);
    }

    return null;
  }

  Widget _buildNotesGrid(Set<int> notes) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final number = index + 1;
          final hasNote = notes.contains(number);
          return Center(
            child: hasNote
                ? Text(
                    number.toString(),
                    style: const TextStyle(
                      fontSize: 8,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  String _getChessPieceSymbol(ChessPiece piece) {
    switch (piece) {
      case ChessPiece.king:
        return '♔';
      case ChessPiece.queen:
        return '♕';
      case ChessPiece.rook:
        return '♖';
      case ChessPiece.bishop:
        return '♗';
      case ChessPiece.knight:
        return '♘';
      case ChessPiece.pawn:
        return '♙';
    }
  }

  Color _getNumberColor(bool isInitial) {
    // 오류가 있는 셀인 경우 빨간색
    if (hasError) {
      return Colors.red;
    }

    // 초기값과 사용자 입력값 모두 검은색으로 통일
    return AppColors.onSurface;
  }

  Color _getCellColor() {
    if (hasError) {
      return Colors.red.withValues(alpha: 0.2);
    }
    if (isSelected) {
      return AppColors.primary.withValues(alpha: 0.3);
    }
    if (isHighlighted) {
      return AppColors.primary.withValues(alpha: 0.1);
    }

    // 초기값이거나 체스 기물이 있는 경우 연한 회색 배경
    if (cellContent?.isInitial == true || cellContent?.chessPiece != null) {
      return Colors.grey.withValues(alpha: 0.1);
    }

    return AppColors.surface;
  }

  bool _shouldShowThickBorder(int index, bool isRow) {
    return index % 3 == 0;
  }
}

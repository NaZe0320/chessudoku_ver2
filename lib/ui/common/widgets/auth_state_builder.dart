import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessudoku/data/models/user.dart';
import 'package:chessudoku/core/di/auth_providers.dart';

class AuthStateBuilder extends ConsumerWidget {
  final Widget Function(User user) authenticatedBuilder;
  final Widget Function() unauthenticatedBuilder;
  final Widget Function()? loadingBuilder;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  const AuthStateBuilder({
    super.key,
    required this.authenticatedBuilder,
    required this.unauthenticatedBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) =>
          user != null ? authenticatedBuilder(user) : unauthenticatedBuilder(),
      loading: () =>
          loadingBuilder?.call() ??
          const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          errorBuilder?.call(error, stackTrace) ??
          Center(child: Text('오류가 발생했습니다: $error')),
    );
  }
}

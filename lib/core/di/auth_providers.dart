import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chessudoku/data/models/user.dart';
import 'package:chessudoku/data/repositories/firebase_auth_repository.dart';
import 'package:chessudoku/domain/notifiers/auth_notifier.dart';
import 'package:chessudoku/domain/intents/auth_intent.dart';

/// Firebase Auth Provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// SharedPreferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized before use');
});

/// Firebase Auth Repository Provider
final firebaseAuthRepositoryProvider = Provider<FirebaseAuthRepository>((ref) {
  return FirebaseAuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

/// Auth State Provider
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});

/// Auth Intent Provider
final authIntentProvider = Provider<AuthIntent>((ref) {
  return AuthIntent(ref);
});

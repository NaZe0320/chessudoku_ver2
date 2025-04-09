import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chessudoku/data/models/user.dart';

class FirebaseAuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final SharedPreferences _prefs;

  static const String _credentialsKey = 'user_credentials';

  FirebaseAuthRepository(this._firebaseAuth, this._prefs);

  User? _mapFirebaseUser(firebase_auth.User? user) {
    if (user == null) return null;
    return User(
      id: user.uid,
      email: user.email!,
      displayName: user.displayName,
    );
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cacheUserCredentials(email, password);
      return _mapFirebaseUser(result.user);
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cacheUserCredentials(email, password);
      return _mapFirebaseUser(result.user);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _prefs.remove(_credentialsKey);
  }

  Future<User?> getCurrentUser() async {
    return _mapFirebaseUser(_firebaseAuth.currentUser);
  }

  Future<void> cacheUserCredentials(String email, String password) async {
    final credentials = {
      'email': email,
      'password': password,
    };
    await _prefs.setString(_credentialsKey, jsonEncode(credentials));
  }

  Future<User?> signInWithCachedCredentials() async {
    try {
      final credentialsJson = _prefs.getString(_credentialsKey);
      if (credentialsJson == null) return null;

      final credentials = jsonDecode(credentialsJson) as Map<String, dynamic>;
      return signInWithEmailAndPassword(
        credentials['email'] as String,
        credentials['password'] as String,
      );
    } catch (e) {
      return null;
    }
  }
}

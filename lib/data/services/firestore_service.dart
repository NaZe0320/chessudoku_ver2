import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

/// Firestore 데이터베이스 서비스
/// deviceId 기반 사용자 데이터 관리를 담당하는 싱글톤 클래스
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  static FirebaseFirestore? _firestore;

  // 컬렉션 이름
  static const String _usersCollection = 'users';
  static const String _versionsCollection = 'versions';
  static const String _puzzlesCollection = 'puzzles';

  // 싱글톤 패턴 적용
  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  /// Firestore 인스턴스 가져오기
  FirebaseFirestore get firestore {
    if (_firestore != null) return _firestore!;
    _firestore = FirebaseFirestore.instance;
    return _firestore!;
  }

  /// 사용자 문서 참조 가져오기
  DocumentReference _getUserDocument(String deviceId) {
    return firestore.collection(_usersCollection).doc(deviceId);
  }

  /// 사용자 데이터 생성 또는 업데이트
  Future<void> createOrUpdateUser(
      String deviceId, Map<String, dynamic> userData) async {
    try {
      debugPrint('FirestoreService: 사용자 데이터 생성/업데이트 시작 - $deviceId');
      debugPrint('FirestoreService: 데이터 내용 - $userData');

      final docRef = _getUserDocument(deviceId);
      debugPrint('FirestoreService: 문서 참조 생성 완료');

      await docRef.set(userData, SetOptions(merge: true));
      debugPrint('FirestoreService: Firestore에 데이터 저장 완료');

      // 저장 확인
      final savedDoc = await docRef.get();
      if (savedDoc.exists) {
        debugPrint('FirestoreService: 저장된 데이터 확인 완료');
      } else {
        debugPrint('FirestoreService: 저장된 데이터 확인 실패 - 문서가 존재하지 않음');
      }

      debugPrint('FirestoreService: 사용자 데이터 저장 완료');
    } catch (e) {
      debugPrint('FirestoreService: 사용자 데이터 저장 실패 - $e');
      debugPrint('FirestoreService: 오류 타입 - ${e.runtimeType}');
      rethrow;
    }
  }

  /// 사용자 데이터 가져오기
  Future<Map<String, dynamic>?> getUserData(String deviceId) async {
    try {
      debugPrint('FirestoreService: 사용자 데이터 조회 - $deviceId');

      final doc = await _getUserDocument(deviceId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint('FirestoreService: 사용자 데이터 조회 완료');
        return data;
      } else {
        debugPrint('FirestoreService: 사용자 데이터가 존재하지 않음');
        return null;
      }
    } catch (e) {
      debugPrint('FirestoreService: 사용자 데이터 조회 실패 - $e');
      rethrow;
    }
  }

  /// 서버 데이터 버전 정보 가져오기
  Future<Map<String, int>> getServerDataVersions() async {
    try {
      debugPrint('FirestoreService: 서버 데이터 버전 정보 조회 중...');

      final doc =
          await firestore.collection(_versionsCollection).doc('latest').get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final versions = <String, int>{};

        // 각 데이터 타입별 버전 정보 추출
        data.forEach((key, value) {
          if (value is int) {
            versions[key] = value;
          }
        });

        debugPrint('FirestoreService: 서버 버전 정보 조회 완료 - $versions');
        return versions;
      } else {
        debugPrint('FirestoreService: 서버 버전 정보가 존재하지 않음');
        // 기본 버전 정보 반환
        return {
          'puzzles': 1,
          'languages': 1,
          'notices': 1,
        };
      }
    } catch (e) {
      debugPrint('FirestoreService: 서버 버전 정보 조회 실패 - $e');
      // 오류 시 기본 버전 정보 반환
      return {
        'puzzles': 1,
        'languages': 1,
        'notices': 1,
      };
    }
  }

  /// Firebase에서 퍼즐 가져오기
  Future<Map<String, dynamic>?> getPuzzleFromFirebase(
      Difficulty difficulty) async {
    try {
      debugPrint('FirestoreService: 퍼즐 조회 중 - 난이도: ${difficulty.name}');

      // 난이도별 퍼즐 컬렉션에서 랜덤 퍼즐 가져오기
      final querySnapshot = await firestore
          .collection(_puzzlesCollection)
          .doc(difficulty.name) // /puzzles/easy
          .collection('puzzles') // /puzzles/easy/puzzles
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final puzzleData = querySnapshot.docs.first.data();
        debugPrint('FirestoreService: 퍼즐 조회 완료');
        return puzzleData;
      } else {
        debugPrint('FirestoreService: 해당 난이도의 퍼즐이 존재하지 않음');
        return null;
      }
    } catch (e) {
      debugPrint('FirestoreService: 퍼즐 조회 실패 - $e');
      rethrow;
    }
  }

  /// Firebase에서 특정 퍼즐 ID로 퍼즐 가져오기
  Future<Map<String, dynamic>?> getPuzzleById(
      String puzzleId, Difficulty difficulty) async {
    try {
      debugPrint(
          'FirestoreService: 퍼즐 조회 중 - ID: $puzzleId, 난이도: ${difficulty.name}');

      final doc = await firestore
          .collection(_puzzlesCollection)
          .doc(difficulty.name) // /puzzles/easy
          .collection('puzzles') // /puzzles/easy/puzzles
          .doc(puzzleId) // /puzzles/easy/puzzles/simple_puzzle_001
          .get();

      if (doc.exists) {
        final puzzleData = doc.data() as Map<String, dynamic>;
        debugPrint('FirestoreService: 퍼즐 조회 완료');
        return puzzleData;
      } else {
        debugPrint('FirestoreService: 해당 ID의 퍼즐이 존재하지 않음');
        return null;
      }
    } catch (e) {
      debugPrint('FirestoreService: 퍼즐 조회 실패 - $e');
      rethrow;
    }
  }
}

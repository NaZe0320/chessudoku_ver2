import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore 데이터베이스 서비스
/// deviceId 기반 사용자 데이터 관리를 담당하는 싱글톤 클래스
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  static FirebaseFirestore? _firestore;

  // 컬렉션 이름
  static const String _usersCollection = 'users';

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
      debugPrint('FirestoreService: 사용자 데이터 생성/업데이트 - $deviceId');

      await _getUserDocument(deviceId).set(userData, SetOptions(merge: true));

      debugPrint('FirestoreService: 사용자 데이터 저장 완료');
    } catch (e) {
      debugPrint('FirestoreService: 사용자 데이터 저장 실패 - $e');
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
}

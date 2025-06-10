import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chessudoku/data/models/user.dart';
import 'package:flutter/material.dart';

/// Firestore 데이터베이스 서비스
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // 컬렉션 이름
  static const String _usersCollection = 'users';
  static const String _deviceMappingCollection = 'device_mappings';
  
  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  /// 디바이스 ID로 기존 사용자 계정 찾기
  Future<User?> findUserByDeviceId(String deviceId) async {
    try {
      debugPrint('FirestoreService: 디바이스 ID로 사용자 검색 - ${deviceId.substring(0, 8)}...');
      
      // device_mappings 컬렉션에서 디바이스 ID로 사용자 ID 찾기
      final deviceMappingQuery = await _firestore
          .collection(_deviceMappingCollection)
          .where('deviceId', isEqualTo: deviceId)
          .limit(1)
          .get();

      if (deviceMappingQuery.docs.isEmpty) {
        debugPrint('FirestoreService: 해당 디바이스 ID의 매핑 정보 없음');
        return null;
      }

      final mappingDoc = deviceMappingQuery.docs.first;
      final userId = mappingDoc.data()['userId'] as String?;
      
      if (userId == null) {
        debugPrint('FirestoreService: 매핑에서 사용자 ID를 찾을 수 없음');
        return null;
      }

      // 사용자 정보 가져오기
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        debugPrint('FirestoreService: 사용자 문서가 존재하지 않음');
        return null;
      }

      final userData = userDoc.data()!;
      final user = User.fromJson({
        'id': userDoc.id,
        ...userData,
      });

      debugPrint('FirestoreService: 기존 사용자 찾음 - ${user.email}');
      return user;
    } catch (e) {
      debugPrint('FirestoreService: 디바이스 ID로 사용자 검색 중 오류: $e');
      return null;
    }
  }

  /// 새 사용자 계정 생성 및 디바이스 매핑
  Future<void> createUserWithDeviceMapping({
    required User user,
    required String deviceId,
  }) async {
    try {
      debugPrint('FirestoreService: 새 사용자 생성 및 디바이스 매핑 - ${user.email}');
      
      final batch = _firestore.batch();
      final now = DateTime.now();

      // 1. 사용자 문서 생성
      final userRef = _firestore.collection(_usersCollection).doc(user.id);
      final userData = user.copyWith(
        deviceId: deviceId,
        createdAt: user.createdAt ?? now,
        lastLoginAt: now,
      ).toJson();

      batch.set(userRef, userData);

      // 2. 디바이스 매핑 생성
      final deviceMappingRef = _firestore
          .collection(_deviceMappingCollection)
          .doc(deviceId);
      
      batch.set(deviceMappingRef, {
        'deviceId': deviceId,
        'userId': user.id,
        'createdAt': now.toIso8601String(),
        'lastUsedAt': now.toIso8601String(),
      });

      // 3. 배치 실행
      await batch.commit();
      
        debugPrint('FirestoreService: 사용자 생성 및 디바이스 매핑 완료');
    } catch (e) {
      debugPrint('FirestoreService: 사용자 생성 및 디바이스 매핑 중 오류: $e');
      rethrow;
    }
  }

  /// 기존 사용자의 로그인 시간 업데이트
  Future<void> updateUserLastLogin(String userId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
      
      debugPrint('FirestoreService: 사용자 로그인 시간 업데이트 완료');
    } catch (e) {
      debugPrint('FirestoreService: 로그인 시간 업데이트 중 오류: $e');
    }
  }

  /// 디바이스 매핑의 마지막 사용 시간 업데이트
  Future<void> updateDeviceMappingLastUsed(String deviceId) async {
    try {
      await _firestore
          .collection(_deviceMappingCollection)
          .doc(deviceId)
          .update({
        'lastUsedAt': DateTime.now().toIso8601String(),
      });
      
      debugPrint('FirestoreService: 디바이스 매핑 사용 시간 업데이트 완료');
    } catch (e) {
      debugPrint('FirestoreService: 디바이스 매핑 업데이트 중 오류: $e');
    }
  }

  /// 사용자 정보 업데이트
  Future<void> updateUser(User user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .update(user.toJson());
      
      debugPrint('FirestoreService: 사용자 정보 업데이트 완료');
    } catch (e) {
      debugPrint('FirestoreService: 사용자 정보 업데이트 중 오류: $e');
      rethrow;
    }
  }

  /// 디바이스 매핑 삭제 (로그아웃 시)
  Future<void> removeDeviceMapping(String deviceId) async {
    try {
      await _firestore
          .collection(_deviceMappingCollection)
          .doc(deviceId)
          .delete();
      
      debugPrint('FirestoreService: 디바이스 매핑 삭제 완료');
    } catch (e) {
      debugPrint('FirestoreService: 디바이스 매핑 삭제 중 오류: $e');
    }
  }

  /// 사용자의 모든 디바이스 매핑 조회
  Future<List<Map<String, dynamic>>> getUserDeviceMappings(String userId) async {
    try {
      final query = await _firestore
          .collection(_deviceMappingCollection)
          .where('userId', isEqualTo: userId)
          .get();

      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      debugPrint('FirestoreService: 사용자 디바이스 매핑 조회 중 오류: $e');
      return [];
    }
  }

  /// 오래된 디바이스 매핑 정리 (30일 이상 미사용)
  Future<void> cleanupOldDeviceMappings() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      
      final query = await _firestore
          .collection(_deviceMappingCollection)
          .where('lastUsedAt', isLessThan: cutoffDate.toIso8601String())
          .get();

      final batch = _firestore.batch();
      for (final doc in query.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('FirestoreService: 오래된 디바이스 매핑 ${query.docs.length}개 정리 완료');
    } catch (e) {
      debugPrint('FirestoreService: 오래된 디바이스 매핑 정리 중 오류: $e');
    }
  }

  /// 사용자 계정 완전 삭제
  Future<void> deleteUserAccount(String userId) async {
    try {
      final batch = _firestore.batch();

      // 1. 사용자 문서 삭제
      final userRef = _firestore.collection(_usersCollection).doc(userId);
      batch.delete(userRef);

      // 2. 해당 사용자의 모든 디바이스 매핑 삭제
      final deviceMappings = await getUserDeviceMappings(userId);
      for (final mapping in deviceMappings) {
        final mappingRef = _firestore.collection(_deviceMappingCollection).doc(mapping['id']);
        batch.delete(mappingRef);
      }

      await batch.commit();
      debugPrint('FirestoreService: 사용자 계정 완전 삭제 완료');
    } catch (e) {
      debugPrint('FirestoreService: 사용자 계정 삭제 중 오류: $e');
      rethrow;
    }
  }
}
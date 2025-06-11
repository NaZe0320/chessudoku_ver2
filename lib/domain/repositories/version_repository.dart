abstract class VersionRepository {
  /// 앱 시작 시 서버와 로컬 데이터 버전을 비교하고 필요한 데이터를 동기화합니다.
  Future<void> checkVersionAndSync();
}

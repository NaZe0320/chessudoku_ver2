import 'package:chessudoku/core/base/base_intent.dart';

/// 사용자 관련 Intent 정의
sealed class UserIntent extends BaseIntent {}

/// 사용자 초기화 (스플래시에서 호출)
class InitializeUserIntent extends UserIntent {}

/// 사용자 탈퇴 (앱 종료)
class WithdrawUserIntent extends UserIntent {}

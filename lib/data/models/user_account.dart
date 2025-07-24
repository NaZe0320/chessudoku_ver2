import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_account.freezed.dart';
part 'user_account.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String deviceId,
    @Default(0) int completedPuzzles,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0) int totalPlayTime,
    DateTime? lastCompletedDate,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

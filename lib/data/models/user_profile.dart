import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String deviceId,
    required String username,
    required DateTime createdAt,
    required DateTime lastLoginAt,
    @Default(0) int totalPlayTime,
    @Default(0) int completedPuzzles,
    @Default(0) int currentStreak,
    @Default(0) int bestStreak,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

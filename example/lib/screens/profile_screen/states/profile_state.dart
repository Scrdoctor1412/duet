import 'package:flutter/foundation.dart';

@immutable
class ProfileData {
  final String name;
  final String email;
  final String phone;
  final String bio;
  final bool notificationsEnabled;
  final bool isEditing;

  const ProfileData({
    this.name = 'Nguy   n V  n A',
    this.email = 'nguyenvana@example.com',
    this.phone = '0901234567',
    this.bio = 'Flutter Developer   am m   h   c h   i c  ng ngh   ?m   i.',
    this.notificationsEnabled = true,
    this.isEditing = false,
  });

  ProfileData copyWith({
    String? name,
    String? email,
    String? phone,
    String? bio,
    bool? notificationsEnabled,
    bool? isEditing,
  }) {
    return ProfileData(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

sealed class ProfileUiBehavior {
  const ProfileUiBehavior();
}

class ProfileUiIdle extends ProfileUiBehavior {
  const ProfileUiIdle();
}

class ProfileUiLoading extends ProfileUiBehavior {
  const ProfileUiLoading();
}

class ProfileUiSuccess extends ProfileUiBehavior {
  final String message;
  final DateTime createdAt;

  ProfileUiSuccess(this.message) : createdAt = DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileUiSuccess && createdAt == other.createdAt;

  @override
  int get hashCode => createdAt.hashCode;
}

class ProfileUiError extends ProfileUiBehavior {
  final String message;
  final DateTime createdAt;

  ProfileUiError(this.message) : createdAt = DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileUiError && createdAt == other.createdAt;

  @override
  int get hashCode => createdAt.hashCode;
}

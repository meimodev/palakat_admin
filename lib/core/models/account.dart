import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

enum UserRole {
  @JsonValue('administrator')
  administrator,
  @JsonValue('moderator')
  moderator,
  @JsonValue('member')
  member,
}

enum AccountStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('suspended')
  suspended,
}

@freezed
class Account with _$Account {
  const Account._();

  const factory Account({
    required String id,
    required String name,
    required String email,
    required String phone,
    String? profileImageUrl,
    required UserRole role,
    required AccountStatus status,
    required DateTime memberSince,
    DateTime? lastLogin,
    String? department,
    String? position,
    @Default(false) bool emailVerified,
    @Default(false) bool phoneVerified,
    @Default(false) bool twoFactorEnabled,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  String get roleDisplayName {
    switch (role) {
      case UserRole.administrator:
        return 'Administrator';
      case UserRole.moderator:
        return 'Moderator';
      case UserRole.member:
        return 'Member';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case AccountStatus.active:
        return 'Active';
      case AccountStatus.inactive:
        return 'Inactive';
      case AccountStatus.suspended:
        return 'Suspended';
    }
  }

  Color get statusColor {
    switch (status) {
      case AccountStatus.active:
        return Colors.green;
      case AccountStatus.inactive:
        return Colors.orange;
      case AccountStatus.suspended:
        return Colors.red;
    }
  }
}

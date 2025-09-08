import 'package:flutter/material.dart';

enum UserRole {
  administrator,
  moderator,
  member,
}

enum AccountStatus {
  active,
  inactive,
  suspended,
}

class Account {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final UserRole role;
  final AccountStatus status;
  final DateTime memberSince;
  final DateTime? lastLogin;
  final String? department;
  final String? position;
  final bool emailVerified;
  final bool phoneVerified;
  final bool twoFactorEnabled;

  const Account({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    required this.role,
    required this.status,
    required this.memberSince,
    this.lastLogin,
    this.department,
    this.position,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.twoFactorEnabled = false,
  });

  Account copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    UserRole? role,
    AccountStatus? status,
    DateTime? memberSince,
    DateTime? lastLogin,
    String? department,
    String? position,
    bool? emailVerified,
    bool? phoneVerified,
    bool? twoFactorEnabled,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      memberSince: memberSince ?? this.memberSince,
      lastLogin: lastLogin ?? this.lastLogin,
      department: department ?? this.department,
      position: position ?? this.position,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
    );
  }

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

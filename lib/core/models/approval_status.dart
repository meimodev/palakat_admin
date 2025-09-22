import 'package:json_annotation/json_annotation.dart';

enum ApprovalStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
}

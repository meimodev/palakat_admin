import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/core/models/member_position.dart';

part 'membership.freezed.dart';
part 'membership.g.dart';

@freezed
abstract class Membership with _$Membership {
  const factory Membership({
    required int id,
    required bool baptize,
    required bool sidi,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<MemberPosition> membershipPositions,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);
}

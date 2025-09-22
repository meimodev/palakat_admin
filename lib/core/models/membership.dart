import 'package:freezed_annotation/freezed_annotation.dart';

part 'membership.freezed.dart';
part 'membership.g.dart';

@freezed
class Membership with _$Membership {
  const Membership._();

  const factory Membership({
    required String name,
    required String email,
    required String phone,
    required List<String> positions,
    @Default(false) bool isBaptized,
    @Default(false) bool isSidi,
    @Default(false) bool isLinked,
    @Default(false) bool isMarried,
    String? gender,
    DateTime? dateOfBirth,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> json) => _$MembershipFromJson(json);

  // Helper method to create an AppMember with a single position for backward compatibility
  factory Membership.singlePosition({
    required String name,
    required String email,
    required String phone,
    required String position,
    bool isBaptized = false,
    bool isSidi = false,
    bool isLinked = false,
    bool isMarried = false,
    DateTime? dateOfBirth,
  }) {
    return Membership(
      name: name,
      email: email,
      phone: phone,
      positions: [position],
      isBaptized: isBaptized,
      isSidi: isSidi,
      isLinked: isLinked,
      isMarried: isMarried,
      dateOfBirth: dateOfBirth,
    );
  }
}
import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_position.freezed.dart';
part 'member_position.g.dart';

@freezed
abstract class MemberPosition with _$MemberPosition {
  const factory MemberPosition({
    required int id,
    required int churchId,
    required int columnId,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MemberPosition;

  factory MemberPosition.fromJson(Map<String, dynamic> data) =>
      _$MemberPositionFromJson(data);
}

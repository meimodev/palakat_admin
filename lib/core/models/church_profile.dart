import 'package:freezed_annotation/freezed_annotation.dart';

part 'church_profile.freezed.dart';
part 'church_profile.g.dart';

@freezed
class ChurchProfile with _$ChurchProfile {
  const factory ChurchProfile({
    required String id,
    required String name,
    required String address,
    required String phoneNumber,
    required String email,
    required String aboutChurch,
    double? latitude,
    double? longitude,
    String? serviceSchedule,
    required List<ChurchColumn> columns,
    required List<ChurchPosition> positions,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ChurchProfile;

  factory ChurchProfile.fromJson(Map<String, dynamic> json) => _$ChurchProfileFromJson(json);
}

@freezed
class ChurchColumn with _$ChurchColumn {
  const factory ChurchColumn({
    required String id,
    required int number,
    required String name,
    required DateTime createdAt,
  }) = _ChurchColumn;

  factory ChurchColumn.fromJson(Map<String, dynamic> json) => _$ChurchColumnFromJson(json);
}

@freezed
class ChurchPosition with _$ChurchPosition {
  const factory ChurchPosition({
    required String id,
    required String name,
    String? description,
    required DateTime createdAt,
  }) = _ChurchPosition;

  factory ChurchPosition.fromJson(Map<String, dynamic> json) => _$ChurchPositionFromJson(json);
}

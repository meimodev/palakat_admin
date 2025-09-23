import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';
part 'location.g.dart';

@freezed
abstract class Location with _$Location {
  const factory Location({
    required int id,
    required String name,
    required double latitude,
    required double longitude,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
}

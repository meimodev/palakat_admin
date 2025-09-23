import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/core/constants/enums.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';



@freezed
abstract class Activity with _$Activity {
  const factory Activity({
    required String id,
    required String title,
    required String description,
    required ActivityType type,
    required ActivityStatus status,
    required DateTime startDate,
    DateTime? endDate,
    required String supervisor,
    required List<String> supervisorPositions,
    required List<String> participants,
    String? location,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);
}



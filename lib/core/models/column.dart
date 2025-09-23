import 'package:freezed_annotation/freezed_annotation.dart';

part 'column.freezed.dart';
part 'column.g.dart';

@freezed
abstract class Column with _$Column {
  const factory Column({
    required String id,
    required int number,
    required String name,
    required DateTime createdAt,
  }) = _Column;

  factory Column.fromJson(Map<String, dynamic> json) => _$ColumnFromJson(json);
}

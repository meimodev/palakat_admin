import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';
part 'document.g.dart';

@freezed
class Document with _$Document {
  const factory Document({
    required String id,
    required String name,
    required String identityNumber,
    required DateTime approvedDate,
    required String type,
    required String status,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);
}

@freezed
class DocumentSettings with _$DocumentSettings {
  const factory DocumentSettings({
    required String identityNumberTemplate,
  }) = _DocumentSettings;

  factory DocumentSettings.fromJson(Map<String, dynamic> json) => _$DocumentSettingsFromJson(json);
}

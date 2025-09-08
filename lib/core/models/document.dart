class Document {
  final String id;
  final String name;
  final String identityNumber;
  final DateTime approvedDate;
  final String type;
  final String status;

  const Document({
    required this.id,
    required this.name,
    required this.identityNumber,
    required this.approvedDate,
    required this.type,
    required this.status,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      name: json['name'] as String,
      identityNumber: json['identityNumber'] as String,
      approvedDate: DateTime.parse(json['approvedDate'] as String),
      type: json['type'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'identityNumber': identityNumber,
      'approvedDate': approvedDate.toIso8601String(),
      'type': type,
      'status': status,
    };
  }

  Document copyWith({
    String? id,
    String? name,
    String? identityNumber,
    DateTime? approvedDate,
    String? type,
    String? status,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      identityNumber: identityNumber ?? this.identityNumber,
      approvedDate: approvedDate ?? this.approvedDate,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }
}

class DocumentSettings {
  final String identityNumberTemplate;

  const DocumentSettings({
    required this.identityNumberTemplate,
  });

  factory DocumentSettings.fromJson(Map<String, dynamic> json) {
    return DocumentSettings(
      identityNumberTemplate: json['identityNumberTemplate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identityNumberTemplate': identityNumberTemplate,
    };
  }

  DocumentSettings copyWith({
    String? identityNumberTemplate,
  }) {
    return DocumentSettings(
      identityNumberTemplate: identityNumberTemplate ?? this.identityNumberTemplate,
    );
  }
}

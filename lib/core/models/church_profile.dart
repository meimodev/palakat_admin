class ChurchProfile {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final String email;
  final String aboutChurch;
  final double? latitude;
  final double? longitude;
  final String? serviceSchedule;
  final List<ChurchColumn> columns;
  final List<ChurchPosition> positions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChurchProfile({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.aboutChurch,
    this.latitude,
    this.longitude,
    this.serviceSchedule,
    required this.columns,
    required this.positions,
    required this.createdAt,
    required this.updatedAt,
  });

  ChurchProfile copyWith({
    String? id,
    String? name,
    String? address,
    String? phoneNumber,
    String? email,
    String? aboutChurch,
    double? latitude,
    double? longitude,
    String? serviceSchedule,
    List<ChurchColumn>? columns,
    List<ChurchPosition>? positions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChurchProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      aboutChurch: aboutChurch ?? this.aboutChurch,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      serviceSchedule: serviceSchedule ?? this.serviceSchedule,
      columns: columns ?? this.columns,
      positions: positions ?? this.positions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ChurchColumn {
  final String id;
  final int number;
  final String name;
  final DateTime createdAt;

  const ChurchColumn({
    required this.id,
    required this.number,
    required this.name,
    required this.createdAt,
  });

  ChurchColumn copyWith({
    String? id,
    int? number,
    String? name,
    DateTime? createdAt,
  }) {
    return ChurchColumn(
      id: id ?? this.id,
      number: number ?? this.number,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ChurchPosition {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  const ChurchPosition({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  ChurchPosition copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return ChurchPosition(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Membership {
  final String name;
  final String email;
  final String phone;
  final List<String> positions;
  final bool isBaptized;
  final bool isSidi;
  final bool isLinked;
  final bool isMarried;
  final String? gender;

  const Membership({
    required this.name,
    required this.email,
    required this.phone,
    required this.positions,
    this.isBaptized = false,
    this.isSidi = false,
    this.isLinked = false,
    this.isMarried = false,
    this.gender,
  });

  Membership copyWith({
    String? name,
    String? email,
    String? phone,
    List<String>? positions,
    bool? isBaptized,
    bool? isSidi,
    bool? isLinked,
    bool? isMarried,
    String? gender,
  }) {
    return Membership(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      positions: positions ?? List.from(this.positions),
      isBaptized: isBaptized ?? this.isBaptized,
      isSidi: isSidi ?? this.isSidi,
      isLinked: isLinked ?? this.isLinked,
      isMarried: isMarried ?? this.isMarried,
      gender: gender ?? this.gender,
    );
  }

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
    );
  }
}
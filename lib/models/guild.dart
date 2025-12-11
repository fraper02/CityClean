class Guild {
  final String id;
  final String name;
  final String description;
  final int membersCount;
  final int maxCapacity;
  final String creatorId;

  Guild({
    required this.id,
    required this.name,
    required this.description,
    required this.membersCount,
    required this.maxCapacity,
    required this.creatorId,
  });

  factory Guild.fromMap(Map<String, dynamic> map) {
    // Il conteggio dei membri non viene più dall'array, ma da un calcolo del service.
    final members = map['members_count'] as int? ?? 0;

    return Guild(
      id: map['idparty'] as String? ?? '',
      name: map['nome'] as String? ?? 'Nome non disponibile',
      creatorId: map['idcreatore'] as String? ?? '',
      description: 'Gilda ufficiale di CityClean', // Placeholder
      membersCount: members,
      maxCapacity: map['capienzamassima'] as int? ?? 0,
    );
  }
}

class Guild {
  final String id;
  final String name;
  final String description;
  final int membersCount;
  final int maxCapacity;
  final String creatorId;       // NUOVO: ID del creatore
  final List<String> memberIds; // NUOVO: Lista degli ID dei membri

  Guild({
    required this.id,
    required this.name,
    required this.description,
    required this.membersCount,
    required this.maxCapacity,
    required this.creatorId,
    required this.memberIds,
  });

  // Factory per creare un'istanza da una mappa (es. dati JSON da Supabase)
  factory Guild.fromMap(Map<String, dynamic> map) {
    List<String> members = [];
    final dynamic membersData = map['membriid'];

    // Gestisce sia il formato stringa (es. '{id1,id2}') che il formato lista
    if (membersData is String) {
      final cleanedString = membersData.replaceAll(RegExp(r'[{}]'), '').trim();
      if (cleanedString.isNotEmpty) {
        members = cleanedString.split(',').map((e) => e.trim()).toList();
      }
    } else if (membersData is List) {
      members = List<String>.from(membersData);
    }

    return Guild(
      id: map['idparty'] as String? ?? '',
      name: map['nome'] as String? ?? 'Nome non disponibile',
      creatorId: map['idcreatore'] as String? ?? '',
      description: 'Gilda ufficiale di CityClean', // Placeholder
      memberIds: members,
      membersCount: members.length,
      maxCapacity: map['capienzamassima'] as int? ?? 0,
    );
  }
}

class Guild {
  final String id;
  final String name;
  final String description;
  final int membersCount;
  final String? imageUrl; // Opzionale, per il logo della gilda

  Guild({
    required this.id,
    required this.name,
    required this.description,
    required this.membersCount,
    this.imageUrl,
  });
}
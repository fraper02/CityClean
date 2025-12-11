class TemporaryGroupMember {
  final String id;
  final String name;
  final String? surname;
  final String? profilePictureUrl;

  TemporaryGroupMember({
    required this.id,
    required this.name,
    this.surname,
    this.profilePictureUrl,
  });

  factory TemporaryGroupMember.fromMap(Map<String, dynamic> map) {
    return TemporaryGroupMember(
      id: map['idutente'] as String? ?? '',
      name: map['nome'] as String? ?? 'Utente Sconosciuto',
      surname: map['cognome'] as String?,
      profilePictureUrl: map['fotoprofilo'] as String?,
    );
  }
}

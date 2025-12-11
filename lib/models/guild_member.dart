class GuildMember {
  final String id;
  final String name;
  final String? surname;
  final String? referralCode; // MODIFICATO: da title a referralCode
  final String? profilePictureUrl;

  GuildMember({
    required this.id,
    required this.name,
    this.surname,
    this.referralCode,
    this.profilePictureUrl,
  });

  factory GuildMember.fromMap(Map<String, dynamic> map) {
    return GuildMember(
      id: map['idutente'] as String? ?? '',
      name: map['nome'] as String? ?? 'Utente Sconosciuto',
      surname: map['cognome'] as String?,
      // MODIFICA: Legge 'codicereferral' invece di 'titolo'
      referralCode: map['codicereferral'] as String?,
      profilePictureUrl: map['fotoprofilo'] as String?,
    );
  }
}

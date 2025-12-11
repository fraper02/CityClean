class Segnalazione {
  final String id;
  final String userId;
  final String? userEmail;
  final double? longitude;
  final double? latitude;
  final String? pollutionLevel;
  final String? pollutionType;
  final String? status;
  final DateTime? lastUpdated;
  final String? fonteDato; // Nuovo campo
  final bool? accettata; // Nuovo campo

  Segnalazione({
    required this.id,
    required this.userId,
    this.userEmail,
    this.longitude,
    this.latitude,
    this.pollutionLevel,
    this.pollutionType,
    this.status,
    this.lastUpdated,
    this.fonteDato,
    this.accettata,
  });

  factory Segnalazione.fromJson(Map<String, dynamic> json) {
    return Segnalazione(
      id: json['idsegnalazione'] as String,
      userId: json['idutente'] as String,
      userEmail: json['utente'] != null ? json['utente']['email'] as String? : 'N/D',
      longitude: (json['longitudine'] as num?)?.toDouble(),
      latitude: (json['latitudine'] as num?)?.toDouble(),
      pollutionLevel: json['livelloinquinamento'] as String?,
      pollutionType: json['tipoinquinamento'] as String?,
      status: json['stato'] as String?,
      lastUpdated: json['ultimoaggiornamento'] != null
          ? DateTime.parse(json['ultimoaggiornamento'] as String)
          : null,
      fonteDato: json['fontedato'] as String?,
      accettata: json['accettata'] as bool?,
    );
  }
}

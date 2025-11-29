class PrizePossession {
  final String id;
  final String userId;
  final String prizeId;
  final DateTime acquiredAt; // Utile per sapere QUANDO è stato ottenuto

  PrizePossession({
    required this.id,
    required this.userId,
    required this.prizeId,
    required this.acquiredAt,
  });

  // DA SUPABASE A FLUTTER
  factory PrizePossession.fromJson(Map<String, dynamic> json) {
    return PrizePossession(
      id: json['id'] ?? '', // Gestione sicurezza se l'id manca

      // Mappatura CamelCase come richiesto
      userId: json['idUtente'],
      prizeId: json['idPremio'],

      // Se nel DB non hai la data, usa l'ora attuale come fallback
      acquiredAt: json['dataAcquisizione'] != null
          ? DateTime.parse(json['dataAcquisizione'])
          : DateTime.now(),
    );
  }

  // DA FLUTTER A SUPABASE
  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // Solitamente l'ID è auto-generato dal DB, quindi non lo inviamo in creazione
      'idUtente': userId,
      'idPremio': prizeId,
      'dataAcquisizione': acquiredAt.toIso8601String(),
    };
  }
}
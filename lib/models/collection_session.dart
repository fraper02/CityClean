class CollectionSession {
  final String id;
  final DateTime data;
  final int puntiGuadagnati;
  final String idUtente;
  final String idPuntoRaccolta;
  final List<dynamic> rifiutiRaccolti;

  CollectionSession({
    required this.id,
    required this.data,
    required this.puntiGuadagnati,
    required this.idUtente,
    required this.idPuntoRaccolta,
    required this.rifiutiRaccolti,
  });

  factory CollectionSession.fromJson(Map<String, dynamic> json) {
    return CollectionSession(
      id: json['id'],
      data: DateTime.parse(json['data']),
      // DB camelCase
      puntiGuadagnati: json['puntiGuadagnati'],
      idUtente: json['idUtente'],
      idPuntoRaccolta: json['idPuntoRaccolta'],
      rifiutiRaccolti: json['rifiutiRaccolti'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data.toIso8601String(),
      'puntiGuadagnati': puntiGuadagnati,
      'idUtente': idUtente,
      'idPuntoRaccolta': idPuntoRaccolta,
      'rifiutiRaccolti': rifiutiRaccolti,
    };
  }
}
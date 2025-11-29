// lib/models/prize_possession.dart

class PrizePossession {
  final String idRiscatto;
  final String userId;
  final String prizeId;
  final DateTime acquiredAt;

  PrizePossession({
    required this.idRiscatto,
    required this.userId,
    required this.prizeId,
    required this.acquiredAt,
  });

  // Converte i dati del DB in un oggetto Dart.
  // I nomi delle chiavi (es. 'idRiscatto') devono corrispondere esattamente
  // a quelli restituiti dal DB.
  factory PrizePossession.fromJson(Map<String, dynamic> json) {
    return PrizePossession(
      idRiscatto: json['idRiscatto'],
      userId: json['idutente'],
      prizeId: json['idpremio'],
      acquiredAt: DateTime.parse(json['dataAcquisizione']),
    );
  }

  // Converte l'oggetto Dart in JSON. Utile per vari scopi, ma non per l'inserimento
  // se l'ID è generato dal DB.
  Map<String, dynamic> toJson() {
    return {
      'idRiscatto': idRiscatto,
      'idutente': userId,
      'idpremio': prizeId,
      'dataAcquisizione': acquiredAt.toIso8601String(),
    };
  }
}

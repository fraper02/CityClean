class Ecopoint {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String type;
  // Campi aggiuntivi per le statistiche mensili
  final int monthlyConferimentiCount;
  final int monthlyUniqueUsers;
  final int monthlyTotalPunti; // Usato come proxy per i "rifiuti"

  Ecopoint({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.monthlyConferimentiCount = 0,
    this.monthlyUniqueUsers = 0,
    this.monthlyTotalPunti = 0,
  });

  factory Ecopoint.fromJson(Map<String, dynamic> json) {
    return Ecopoint(
      id: json['idpuntoraccolta'] as String,
      name: json['nome'] as String? ?? 'N/A',
      address: json['indirizzo'] as String? ?? 'N/A',
      latitude: (json['latitudine'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitudine'] as num?)?.toDouble() ?? 0.0,
      type: json['tipologia'] as String? ?? 'N/A',
      // Leggiamo i dati aggregati dalla nuova RPC
      monthlyConferimentiCount: (json['monthly_conferimenti_count'] as num?)?.toInt() ?? 0,
      monthlyUniqueUsers: (json['monthly_unique_users'] as num?)?.toInt() ?? 0,
      monthlyTotalPunti: (json['monthly_total_punti'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idpuntoraccolta': id,
      'nome': name,
      'indirizzo': address,
      'latitudine': latitude,
      'longitudine': longitude,
      'tipologia': type,
    };
  }
}

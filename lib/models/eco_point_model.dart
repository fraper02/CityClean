import 'package:latlong2/latlong.dart';

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
  final int monthlyTotalPunti;

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

  // GETTER AGGIUNTO PER LA MAPPA
  // Questo permette alla UI della mappa di usare "point.location" senza cambiare il resto della classe
  LatLng get location => LatLng(latitude, longitude);

  factory Ecopoint.fromJson(Map<String, dynamic> json) {
    // Helper per coordinate sicure (gestisce sia numeri che stringhe con virgola)
    double parseCoord(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
      return 0.0;
    }

    return Ecopoint(
      // toString() protegge nel caso l'ID arrivi come int dal DB
      id: json['idpuntoraccolta']?.toString() ?? '',
      name: json['nome'] as String? ?? 'N/A',
      address: json['indirizzo'] as String? ?? 'N/A',
      latitude: parseCoord(json['latitudine']),
      longitude: parseCoord(json['longitudine']),
      type: json['tipologia'] as String? ?? 'N/A',

      // Dati statistici (opzionali)
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
      'monthly_conferimenti_count': monthlyConferimentiCount,
      'monthly_unique_users': monthlyUniqueUsers,
      'monthly_total_punti': monthlyTotalPunti,
    };
  }
}
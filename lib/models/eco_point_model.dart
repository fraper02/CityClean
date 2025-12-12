import 'package:latlong2/latlong.dart';

class Ecopoint {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String type;

  // Campi statistici (solo lettura)
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

  LatLng get location => LatLng(latitude, longitude);

  factory Ecopoint.fromJson(Map<String, dynamic> json) {
    double parseCoord(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
      return 0.0;
    }

    return Ecopoint(
      id: json['idpuntoraccolta']?.toString() ?? '',
      name: json['nome'] as String? ?? 'N/A',
      address: json['indirizzo'] as String? ?? 'N/A',
      latitude: parseCoord(json['latitudine']),
      longitude: parseCoord(json['longitudine']),
      type: json['tipologia'] as String? ?? 'Generico',

      monthlyConferimentiCount: (json['monthly_conferimenti_count'] as num?)?.toInt() ?? 0,
      monthlyUniqueUsers: (json['monthly_unique_users'] as num?)?.toInt() ?? 0,
      monthlyTotalPunti: (json['monthly_total_punti'] as num?)?.toInt() ?? 0,
    );
  }

  // --- MODIFICA CRUCIALE QUI ---
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      // Includiamo SEMPRE l'ID perché ora lo generiamo noi lato client
      'idpuntoraccolta': id,
      'nome': name,
      'indirizzo': address,
      'latitudine': latitude,
      'longitudine': longitude,
      'tipologia': type,
    };
    return data;
  }
}

// Classe alias per compatibilità
class EcoPointModel extends Ecopoint {
  EcoPointModel({
    required int id,
    required super.name,
    required super.address,
    required LatLng location,
    required super.type,
  }) : super(
    id: id.toString(),
    latitude: location.latitude,
    longitude: location.longitude,
  );

  factory EcoPointModel.fromMap(Map<String, dynamic> map) {
    final ecopoint = Ecopoint.fromJson(map);
    return EcoPointModel(
      id: int.tryParse(ecopoint.id) ?? 0,
      name: ecopoint.name,
      address: ecopoint.address,
      location: ecopoint.location,
      type: ecopoint.type,
    );
  }
}
import 'package:latlong2/latlong.dart';

class MapReportModel {
  final String id;
  final String description;
  final String pollutionLevel;
  final LatLng location;
  final String wasteType;
  final bool isAccepted; // Nuova proprietà per lo stato di accettazione

  MapReportModel({
    required this.id,
    required this.description,
    required this.pollutionLevel,
    required this.location,
    required this.wasteType,
    required this.isAccepted,
  });

  // Factory per creare un oggetto dal JSON di Supabase/PostgreSQL
  factory MapReportModel.fromMap(Map<String, dynamic> map) {
    // Gestione sicura dei double per latitudine/longitudine
    final double lat = (map['latitudine'] is int)
        ? (map['latitudine'] as int).toDouble()
        : (map['latitudine'] as double? ?? 0.0);

    final double lng = (map['longitudine'] is int)
        ? (map['longitudine'] as int).toDouble()
        : (map['longitudine'] as double? ?? 0.0);

    return MapReportModel(
      id: map['id']?.toString() ?? '',
      description: map['descrizione'] ?? 'Nessuna descrizione',
      pollutionLevel: map['livelloinquinamento'] ?? 'N/A',
      wasteType: map['tipoinquinamento'] ?? 'Generico',
      // Leggiamo il campo booleano 'accettata'. Se è null, assumiamo false per sicurezza.
      isAccepted: map['accettata'] ?? false,
      location: LatLng(lat, lng),
    );
  }
}
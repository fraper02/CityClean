import 'package:latlong2/latlong.dart';

// Modello per i Punti di Raccolta (Eco-Compattatori)
class EcoPoint {
  final String id;
  final String name;
  final String type; // Es. "Plastica", "Vetro", "Generico"
  final LatLng location; // Coordinate reali

  EcoPoint({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
  });
}

// Modello per le Zone Inquinate
class PollutedZone {
  final String id;
  final LatLng center; // Centro della zona
  final double radius; // Raggio in metri (o pixel se non usi useRadiusInMeter)
  final String severity; // "Alta", "Media"

  PollutedZone({
    required this.id,
    required this.center,
    required this.radius,
    required this.severity,
  });
}
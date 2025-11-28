import 'package:latlong2/latlong.dart';
import '../models/map_models.dart';

class MockMapData {
  // Lista degli Eco-Compattatori (Coordinate reali di Salerno)
  static final List<EcoPoint> ecoPoints = [
    EcoPoint(
      id: '1',
      name: 'Eco Station Via Roma',
      type: 'Plastica',
      location: const LatLng(40.6763, 14.7664), // Vicino al lungomare
    ),
    EcoPoint(
      id: '2',
      name: 'Raccolta Vetro Porto',
      type: 'Vetro',
      location: const LatLng(40.6780, 14.7600), // Zona porto
    ),
    EcoPoint(
      id: '3',
      name: 'Compattatore Parco',
      type: 'Generico',
      location: const LatLng(40.6680, 14.8050), // Parco del Mercatello
    ),
    EcoPoint(
      id: '4',
      name: 'Stazione Centrale',
      type: 'Plastica',
      location: const LatLng(40.6850, 14.7750), // Stazione FS
    ),
  ];

  // Lista delle Zone Inquinate
  static final List<PollutedZone> pollutedZones = [
    PollutedZone(
      id: 'z1',
      center: const LatLng(40.6740, 14.7580), // Zona Porto commerciale
      radius: 300,
      severity: 'Alta',
    ),
    PollutedZone(
      id: 'z3',
      center: const LatLng(40.675008, 14.771908), // Zona Porto commerciale
      radius: 300,
      severity: 'Alta',
    ),
    PollutedZone(
      id: 'z2',
      center: const LatLng(40.6820, 14.7850), // Zona Torrione
      radius: 200,
      severity: 'Media',
    ),
  ];
}
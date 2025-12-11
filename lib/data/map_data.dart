import 'package:latlong2/latlong.dart';
import '../models/map_models.dart';

class MockMapData {
  // Coordinate reali di Salerno
  static final List<EcoPoint> ecoPoints = [
    EcoPoint(
      id: '1',
      name: 'Eco Station Via Roma',
      type: 'Plastica',
      location: const LatLng(40.6780, 14.7600), // Usa location e LatLng
    ),
    EcoPoint(
      id: '2',
      name: 'Raccolta Vetro Porto',
      type: 'Vetro',
      location: const LatLng(40.6750, 14.7550), // Usa location e LatLng
    ),
    EcoPoint(
      id: '3',
      name: 'Compattatore Parco',
      type: 'Generico',
      location: const LatLng(40.6810, 14.7700), // Usa location e LatLng
    ),
    EcoPoint(
      id: '4',
      name: 'Compattatore Del Sarno2',
      type: 'Generico',
      location: const LatLng(40.7775, 14.5894), // Usa location e LatLng
    ),
  ];

  static final List<PollutedZone> pollutedZones = [
    PollutedZone(
      id: 'z1',
      center: const LatLng(40.6760, 14.7620), // Usa center e LatLng
      radius: 150, // Metri
      severity: 'Alta',
    ),

    PollutedZone(
      id: 'z2',
      center: const LatLng(40.6820, 14.7680), // Usa center e LatLng
      radius: 100,
      severity: 'Media',
    ),
    PollutedZone(
      id: 'z3',
      center: const LatLng(40.7775, 14.5894), // Usa center e LatLng
      radius: 150, // Metri
      severity: 'Alta',
    ),
  ];
}
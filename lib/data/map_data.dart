import 'package:latlong2/latlong.dart';
import '../models/map_models.dart';

class MockMapData {
  // Coordinate reali di Salerno


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
import 'package:latlong2/latlong.dart';

class EcoPoint {
  final String id;
  final String name;
  final String type;
  final LatLng location; // Deve essere location di tipo LatLng

  EcoPoint({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
  });
}

class PollutedZone {
  final String id;
  final LatLng center;
  final double radius;
  final String severity;

  PollutedZone({
    required this.id,
    required this.center,
    required this.radius,
    required this.severity,
  });
}
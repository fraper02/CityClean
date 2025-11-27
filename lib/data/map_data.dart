import '../models/map_models.dart';

class MockMapData {
  // Lista degli Eco-Compattatori
  static final List<EcoPoint> ecoPoints = [
    EcoPoint(id: '1', name: 'Eco Station Via Roma', type: 'Plastica', x: 0.2, y: 0.3),
    EcoPoint(id: '2', name: 'Raccolta Vetro Porto', type: 'Vetro', x: 0.5, y: 0.5),
    EcoPoint(id: '3', name: 'Compattatore Parco', type: 'Generico', x: 0.8, y: 0.2),
    EcoPoint(id: '4', name: 'Stazione Centrale', type: 'Plastica', x: 0.3, y: 0.7),
  ];

  // Lista delle Zone Inquinate
  static final List<PollutedZone> pollutedZones = [
    PollutedZone(id: 'z1', x: 0.4, y: 0.4, radius: 100, severity: 'Alta'),
    PollutedZone(id: 'z2', x: 0.7, y: 0.8, radius: 80, severity: 'Media'),
  ];
}
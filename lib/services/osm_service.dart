import 'dart:convert';
// 1. AGGIUNTO IMPORT NECESSARIO PER debugPrint
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/map_models.dart';

class OsmService {
  final String _overpassUrl = 'https://overpass-api.de/api/interpreter';

  Future<List<EcoPoint>> fetchRecyclingPoints(LatLng center, double radiusInMeters) async {
    final String query = '''
      [out:json][timeout:25];
      (
        node["amenity"="recycling"](around:$radiusInMeters,${center.latitude},${center.longitude});
        node["amenity"="waste_basket"](around:$radiusInMeters,${center.latitude},${center.longitude});
      );
      out body;
    ''';

    try {
      final response = await http.post(
        Uri.parse(_overpassUrl),
        body: 'data=$query',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> elements = data['elements'];

        return elements.map((e) {
          String type = 'Generico';
          if (e['tags'] != null) {
            if (e['tags']['amenity'] == 'recycling') type = 'Riciclaggio';
            if (e['tags']['amenity'] == 'waste_basket') type = 'Cestino';
          }

          return EcoPoint(
            id: e['id'].toString(),
            name: e['tags']?['name'] ?? 'Punto di Raccolta',
            type: type,
            location: LatLng(e['lat'], e['lon']),
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      // 2. SOSTITUITO print CON debugPrint
      debugPrint('Eccezione OSM: $e');
      return [];
    }
  }
}
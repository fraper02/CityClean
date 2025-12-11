import 'package:latlong2/latlong.dart';

class AffiliatedStore {
  final String id;
  final String name;
  final LatLng location;
  final String openHours;
  final String imageUrl;

  AffiliatedStore({
    required this.id,
    required this.name,
    required this.location,
    required this.openHours,
    required this.imageUrl,
  });

  factory AffiliatedStore.fromJson(Map<String, dynamic> json) {
    return AffiliatedStore(
      id: json['id'].toString(),
      name: json['name'],
      location: LatLng(
        (json['latitudine'] ?? json['latitude']).toDouble(),
        (json['longitudine'] ?? json['longitude']).toDouble(),
      ),
      openHours: json['openHours'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

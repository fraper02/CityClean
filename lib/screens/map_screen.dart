import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path; // Fix per il conflitto Path
import 'package:geolocator/geolocator.dart';
import '../components/bottom_nav_bar.dart';
import '../models/map_models.dart';
import '../services/osm_service.dart';
import 'dart:async';
import '../data/map_data.dart';

class MapScreen extends StatefulWidget {

  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final OsmService _osmService = OsmService();

  LatLng _currentCenter = const LatLng(40.6795, 14.7645);
  bool _isLocationLoaded = false;

  List<EcoPoint> _ecoPoints = [];
  List<PollutedZone> _pollutedZones = [];
  bool _isLoading = false;

  // Filtro per i cestini
  bool _showBins = true;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _loadPoints();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _loadPoints();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _loadPoints();
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    if (mounted) {
      setState(() {
        _currentCenter = LatLng(position.latitude, position.longitude);
        _isLocationLoaded = true;
      });
      _mapController.move(_currentCenter, 15.0);
      _loadPoints();
    }
  }

  Future<void> _loadPoints() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1)); //non sembra funzionare

    try {
      final zones = MockMapData.pollutedZones;
      final mockPoints = MockMapData.ecoPoints;

      LatLng centerToUse = _currentCenter;
      try {
        centerToUse = _mapController.camera.center;
      } catch(_) {}

      final realPoints = await _osmService.fetchRecyclingPoints(centerToUse, 2000);

      if (mounted) {
        setState(() {
          _pollutedZones = zones;
          _ecoPoints = [...mockPoints, ...realPoints];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Errore caricamento punti: $e");
      if (mounted) {
        setState(() {
          _pollutedZones = MockMapData.pollutedZones;
          _ecoPoints = MockMapData.ecoPoints;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;

    // FILTRO DELLA LISTA DA MOSTRARE
    final pointsToShow = _showBins
        ? _ecoPoints
        : _ecoPoints.where((p) => p.type != 'Cestino').toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 0),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.unisa.cityclean',
              ),

              CircleLayer(
                circles: _pollutedZones.map((zone) {
                  return CircleMarker(
                    point: zone.center,
                    radius: zone.radius,
                    useRadiusInMeter: true,
                    color: Colors.red.withOpacity(0.3),
                    borderColor: Colors.red.withOpacity(0.7),
                    borderStrokeWidth: 2,
                  );
                }).toList(),
              ),

              MarkerLayer(
                markers: pointsToShow.map((point) {
                  return Marker(
                    point: point.location,
                    width: 50,
                    height: 60,
                    child: _buildCustomEcoMarker(point),
                  );
                }).toList(),
              ),

              if (_isLocationLoaded)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentCenter,
                      width: 25,
                      height: 25,
                      child: const _UserLocationMarker(),
                    ),
                  ],
                ),
            ],
          ),

          // HEADER VERDE (Adattivo)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200, // CORREZIONE: Altezza standardizzata
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20), // Aumentato padding bottom
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Si adatta al contenuto
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Mappa", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 5),
                      const Text("Salerno - Trova punti di interesse", style: TextStyle(fontSize: 16, color: Colors.white70)),
                      const SizedBox(height: 5),
                      // Info punti trovati
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            "Punti visibili: ${pointsToShow.length}",
                            style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // BOTTONE CERCA QUI (Spostato più in basso per non collidere con l'header dinamico)
          Positioned(
            top: 190, // Aumentato da 150 a 190
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _loadPoints,
              icon: _isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2))
                  : const Icon(Icons.refresh, color: Colors.green),
              label: Text(_isLoading ? "Caricamento..." : "Cerca qui"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),

          // SWITCH CESTINI (Basso Sinistra)
          Positioned(
            bottom: 30,
            left: 20,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      Icons.delete_outline,
                      color: _showBins ? Colors.orange[700] : Colors.grey,
                      size: 24
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Cestini",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Switch(
                    value: _showBins,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.orange[400],
                    inactiveThumbColor: Colors.grey[50],
                    inactiveTrackColor: Colors.grey[300],
                    onChanged: (val) {
                      setState(() {
                        _showBins = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // FAB GPS (Basso Destra)
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                await _initializeLocation();
              },
              backgroundColor: primaryGreen,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomEcoMarker(EcoPoint point) {
    final isBin = point.type == 'Cestino';
    final Color markerColor = isBin ? Colors.orange[300]! : Colors.lightGreen[200]!;
    final IconData markerIcon = isBin ? Icons.delete : Icons.location_on_outlined;
    final Color iconColor = Colors.black87;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(point.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Chip(
                  label: Text(point.type),
                  backgroundColor: isBin ? Colors.orange[100] : Colors.green[100],
                  avatar: Icon(isBin ? Icons.delete_outline : Icons.recycling, size: 18, color: isBin ? Colors.orange[800] : Colors.green),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBin ? Colors.orange[700] : Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Chiudi"),
                )
              ],
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: markerColor,
              shape: BoxShape.circle,
              border: Border.all(color: iconColor, width: 2),
            ),
            child: Icon(markerIcon, color: iconColor, size: 24),
          ),
          // Opzionale: triangolino per indicare il punto esatto
          ClipPath(
            clipper: _MarkerClipper(),
            child: Container(
              width: 15,
              height: 10,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Clipper per creare il triangolino sotto al marker
class _MarkerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Widget per il marker dell'utente
class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withOpacity(0.3),
        border: Border.all(color: Colors.blue, width: 3),
      ),
    );
  }
}

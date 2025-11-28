import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // NECESSARIO: flutter_map: ^7.0.2
import 'package:latlong2/latlong.dart' hide Path; // FIX: Nascondiamo 'Path' per evitare conflitti grafici
import '../components/bottom_nav_bar.dart';
import '../models/map_models.dart'; // Ora usiamo i tuoi modelli reali aggiornati
import '../data/map_data.dart';     // Ora usiamo i tuoi dati reali aggiornati

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Controller per muovere la mappa programmaticamente
  final MapController _mapController = MapController();

  // Centro di Salerno (Piazza della Concordia approx)
  final LatLng _salernoCenter = const LatLng(40.6795, 14.7645);

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 0),
      body: Stack(
        children: [
          // 1. LA MAPPA (OpenStreetMap)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _salernoCenter,
              initialZoom: 13.5, // Zoom ideale per vedere tutta Salerno centro
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // A. Sfondo Mappa (Tiles)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // È importante mettere un pacchetto reale per evitare blocchi da OSM
                userAgentPackageName: 'com.unisa.cityclean',
              ),

              // B. ZONE INQUINATE (CircleLayer)
              // Leggiamo direttamente da MockMapData.pollutedZones
              CircleLayer(
                circles: MockMapData.pollutedZones.map((zone) {
                  return CircleMarker(
                    point: zone.center,
                    radius: zone.radius,
                    useRadiusInMeter: true, // IMPORTANTE: Il raggio ora rappresenta metri reali!
                    color: zone.severity == 'Alta'
                        ? Colors.red.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                    borderColor: zone.severity == 'Alta'
                        ? Colors.red.withOpacity(0.6)
                        : Colors.orange.withOpacity(0.6),
                    borderStrokeWidth: 2,
                  );
                }).toList(),
              ),

              // C. ECO-COMPATTATORI (MarkerLayer)
              // Leggiamo direttamente da MockMapData.ecoPoints
              MarkerLayer(
                markers: MockMapData.ecoPoints.map((point) {
                  return Marker(
                    point: point.location,
                    width: 50,
                    height: 60,
                    alignment: Alignment.topCenter,
                    child: _buildCustomEcoMarker(point),
                  );
                }).toList(),
              ),

              // D. POSIZIONE UTENTE (Fittizia per demo)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _salernoCenter, // Mettiamo l'utente al centro per ora
                    width: 25,
                    height: 25,
                    child: const _UserLocationMarker(),
                  ),
                ],
              ),

              // E. CREDITI OSM
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),

          // 2. HEADER VERDE (Fisso in alto)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: const SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mappa",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Salerno - Trova punti di interesse",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. FAB (Centra Posizione)
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                _mapController.move(_salernoCenter, 15.0);
              },
              backgroundColor: primaryGreen,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Costruisce il marker verde interagibile
  Widget _buildCustomEcoMarker(EcoPoint point) {
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
                Text(point.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Chip(
                  label: Text(point.type),
                  backgroundColor: Colors.green[100],
                  avatar: const Icon(Icons.recycling, size: 18, color: Colors.green),
                ),
                const SizedBox(height: 10),
                // Aggiunta descrizione ID per debug
                Text("ID Terminale: ${point.id}", style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Ottieni indicazioni"),
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
              color: Colors.lightGreen[200],
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)],
            ),
            child: const Icon(Icons.location_on_outlined, color: Colors.black87, size: 24),
          ),
          ClipPath(
            clipper: _TriangleClipper(),
            child: Container(
              color: Colors.lightGreen[200],
              width: 10,
              height: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)],
      ),
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path(); // Usa il Path grafico di material.dart grazie all'hide negli import
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
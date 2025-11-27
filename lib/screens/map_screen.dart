import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import '../models/map_models.dart';
import '../data/map_data.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Controller per simulare lo zoom e lo spostamento
  final TransformationController _transformationController = TransformationController();

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Indice 0 per "Mappa"
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 0),
      body: Stack(
        children: [
          // 1. LA MAPPA (Sfondo interattivo)
          // Usiamo InteractiveViewer per simulare una mappa reale (pan & zoom)
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 4.0,
              // Mettiamo un'immagine di mappa generica come sfondo
              child: Stack(
                children: [
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/e/ec/Map_of_Salerno.jpg', // Mappa statica di esempio
                    fit: BoxFit.cover,
                    height: 1000, // Altezza virtuale della mappa
                    width: 1000,  // Larghezza virtuale della mappa
                    color: const Color.fromRGBO(255, 255, 255, 0.8), // Leggera opacità per far risaltare i marker
                    colorBlendMode: BlendMode.modulate,
                  ),

                  // 2. DISEGNO DELLE ZONE INQUINATE (Cerchi Rossi)
                  ...MockMapData.pollutedZones.map((zone) => _buildPollutedZone(zone)),

                  // 3. DISEGNO DEGLI ECO-COMPATTATORI (Marker Verdi)
                  ...MockMapData.ecoPoints.map((point) => _buildEcoMarker(point)),

                  // 4. POSIZIONE UTENTE (Punto Blu - Simulato)
                  const Positioned(
                    left: 500, // Centro della mappa fittizia (1000x1000)
                    top: 500,
                    child: _UserLocationMarker(),
                  ),
                ],
              ),
            ),
          ),

          // 5. HEADER VERDE (Sovrapposto in alto)
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.9), // Leggera trasparenza
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

          // 6. FAB (Bottone in basso a destra per centrare)
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                // Resetta la vista (simula il "Torna alla mia posizione")
                _transformationController.value = Matrix4.identity();
              },
              backgroundColor: primaryGreen,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Zona Inquinata (Cerchio Rosso semitrasparente)
  Widget _buildPollutedZone(PollutedZone zone) {
    return Positioned(
      left: zone.x * 1000 - (zone.radius / 2),
      top: zone.y * 1000 - (zone.radius / 2),
      child: Container(
        width: zone.radius,
        height: zone.radius,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.3), // Rosso semitrasparente
          shape: BoxShape.circle,
          border: Border.all(color: Colors.red.withOpacity(0.6), width: 2),
        ),
        child: const Center(
          child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
        ),
      ),
    );
  }

  // WIDGET: Marker Eco-Point (Pin Verde)
  Widget _buildEcoMarker(EcoPoint point) {
    return Positioned(
      left: point.x * 1000 - 25, // Centra l'icona (width/2)
      top: point.y * 1000 - 50,  // Punta dell'icona in basso (height)
      child: GestureDetector(
        onTap: () {
          // Mostra info al click
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
                color: Colors.lightGreen[200], // Verde chiaro come nell'immagine
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)],
              ),
              child: const Icon(Icons.location_on_outlined, color: Colors.black87, size: 24),
            ),
            // Triangolino sotto per fare l'effetto pin
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
      ),
    );
  }
}

// Widget per la posizione utente (Punto blu pulsante)
class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)],
      ),
    );
  }
}

// Piccolo clipper per disegnare il triangolino sotto il marker
class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
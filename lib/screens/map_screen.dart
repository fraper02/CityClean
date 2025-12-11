import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:image_picker/image_picker.dart';
import '../components/bottom_nav_bar.dart';
import '../controllers/map_controller.dart' as logic;
import '../models/map_report_model.dart';
import '../models/eco_point_model.dart'; // Contiene la classe Ecopoint

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final logic.MapController _controller = logic.MapController();
  final MapController _mapLibController = MapController();

  @override
  void initState() {
    super.initState();
    _controller.initializeLocation().then((_) {
      if(_controller.isLocationLoaded && mounted) {
        _mapLibController.move(_controller.currentCenter, 15.0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helpers grafici
  double _getRadiusByLevel(String level) {
    switch (level.toLowerCase()) {
      case 'basso': return 20.0;
      case 'medio': return 50.0;
      case 'alto': return 100.0;
      case 'critico': return 150.0;
      default: return 30.0;
    }
  }

  Color _getColorByLevel(String level) {
    switch (level.toLowerCase()) {
      case 'critico': return Colors.red.withOpacity(0.5);
      case 'alto': return Colors.red.withOpacity(0.4);
      case 'medio': return Colors.orange.withOpacity(0.4);
      case 'basso': return Colors.yellow.withOpacity(0.4);
      default: return Colors.red.withOpacity(0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 0),
          body: Stack(
            children: [
              // --- MAPPA ---
              FlutterMap(
                mapController: _mapLibController,
                options: MapOptions(
                  initialCenter: _controller.currentCenter,
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.unisa.cityclean',
                  ),

                  // LAYER 1: ZONE ROSSE
                  CircleLayer(
                    circles: _controller.reports.map((report) {
                      return CircleMarker(
                        point: report.location,
                        color: _getColorByLevel(report.pollutionLevel),
                        borderColor: Colors.red.withOpacity(0.8),
                        borderStrokeWidth: 1,
                        useRadiusInMeter: true,
                        radius: _getRadiusByLevel(report.pollutionLevel),
                      );
                    }).toList(),
                  ),

                  // LAYER 2: MARKER REPORT
                  MarkerLayer(
                    markers: _controller.reports.map((report) {
                      return Marker(
                        point: report.location,
                        width: 30,
                        height: 30,
                        child: GestureDetector(
                          onTap: () => _showReportDetails(context, report),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.red, width: 2),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                            ),
                            child: const Center(child: Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // LAYER 3: ECOPOINTS (Usa la classe Ecopoint)
                  MarkerLayer(
                    markers: _controller.ecoPoints.map((point) {
                      return Marker(
                        point: point.location, // Usa il getter che abbiamo aggiunto
                        width: 45,
                        height: 45,
                        child: GestureDetector(
                          onTap: () => _showEcoPointDetails(context, point),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.green[600],
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))],
                                ),
                                child: const Icon(Icons.recycling, color: Colors.white, size: 20),
                              ),
                              ClipPath(
                                clipper: _PinClipper(),
                                child: Container(width: 10, height: 6, color: Colors.green[600]),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // LAYER 4: UTENTE
                  if (_controller.isLocationLoaded)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _controller.currentCenter,
                          width: 25, height: 25,
                          child: Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.withOpacity(0.3), border: Border.all(color: Colors.blue, width: 3)),
                            child: Container(margin: const EdgeInsets.all(4), decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // --- HUD SUPERIORE ---
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.95),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Mappa Green", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.warning, size: 14, color: Colors.redAccent),
                              const SizedBox(width: 4),
                              Text("Segnalazioni: ${_controller.reports.length}", style: const TextStyle(fontSize: 14, color: Colors.white70)),
                              const SizedBox(width: 15),
                              const Icon(Icons.recycling, size: 14, color: Colors.lightGreenAccent),
                              const SizedBox(width: 4),
                              Text("Eco Points: ${_controller.ecoPoints.length}", style: const TextStyle(fontSize: 14, color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // --- BOTTONI LATERALI ---
              Positioned(
                top: 150, right: 20,
                child: ElevatedButton.icon(
                  onPressed: () => _showQuickReportDialog(context),
                  icon: const Icon(Icons.add_alert, size: 20, color: Colors.white),
                  label: const Text("Segnala", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 4),
                ),
              ),
              Positioned(
                top: 200, right: 20,
                child: ElevatedButton.icon(
                  onPressed: _controller.isLoading ? null : _controller.loadData,
                  icon: _controller.isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2)) : const Icon(Icons.refresh, color: Colors.green),
                  label: Text(_controller.isLoading ? "..." : "Aggiorna"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.green[700], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 4),
                ),
              ),
              Positioned(
                bottom: 30, right: 20,
                child: FloatingActionButton(
                  heroTag: "gps_fab",
                  onPressed: () async {
                    await _controller.initializeLocation();
                    if (_controller.isLocationLoaded) {
                      _mapLibController.move(_controller.currentCenter, 15.0);
                    } else {
                      if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("GPS non disponibile")));
                    }
                  },
                  backgroundColor: primaryGreen,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- DIALOGHI ---

  // Dialog aggiornato per usare Ecopoint
  void _showEcoPointDetails(BuildContext context, Ecopoint point) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.recycling, color: Colors.green),
            const SizedBox(width: 10),
            Expanded(child: Text(point.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(child: Text(point.address, style: const TextStyle(fontSize: 16))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.info_outline, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text("Tipologia: ${point.type}", style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: Colors.green[700]),
            child: const Text("Chiudi"),
          )
        ],
      ),
    );
  }

  void _showReportDetails(BuildContext context, MapReportModel report) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Dettaglio Segnalazione"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Livello: ${report.pollutionLevel}"),
            const SizedBox(height: 5),
            Text("Descrizione: ${report.description}"),
            const SizedBox(height: 5),
            Text("Tipo: ${report.wasteType}"),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Chiudi"))],
      ),
    );
  }

  void _showQuickReportDialog(BuildContext parentContext) async {
    final reportDescController = TextEditingController();
    LatLng reportLocation = _controller.currentCenter;
    File? selectedImage;
    String selectedPollutionLevel = 'Medio';
    final List<String> pollutionOptions = ['Basso', 'Medio', 'Alto', 'Critico'];
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: parentContext,
      builder: (ctx) {
        return StatefulBuilder(
            builder: (context, setState) {
              Future<void> pickImage(ImageSource source) async {
                final XFile? photo = await picker.pickImage(source: source, imageQuality: 50);
                if (photo != null) setState(() => selectedImage = File(photo.path));
              }
              bool isDialogUploading = false;

              return AlertDialog(
                title: const Row(children: [Icon(Icons.warning_amber, color: Colors.orange), SizedBox(width: 10), Text("Nuova Segnalazione")]),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => pickImage(ImageSource.camera),
                        child: Container(
                          height: 120, width: double.infinity,
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10), image: selectedImage != null ? DecorationImage(image: FileImage(selectedImage!), fit: BoxFit.cover) : null),
                          child: selectedImage == null ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey) : null,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(controller: reportDescController, decoration: const InputDecoration(labelText: "Descrizione", border: OutlineInputBorder()), maxLines: 2),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: selectedPollutionLevel,
                        decoration: const InputDecoration(labelText: "Livello", border: OutlineInputBorder()),
                        items: pollutionOptions.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                        onChanged: (val) => setState(() => selectedPollutionLevel = val!),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
                  ElevatedButton(
                    onPressed: isDialogUploading ? null : () async {
                      if (reportDescController.text.isEmpty) return;
                      setState(() => isDialogUploading = true);
                      bool success = await _controller.submitReport(
                          description: reportDescController.text,
                          pollutionLevel: selectedPollutionLevel,
                          location: reportLocation,
                          imageFile: selectedImage
                      );
                      if (parentContext.mounted) {
                        Navigator.pop(context);
                        if (success) {
                          ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text("Inviata!")));
                        } else {
                          ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text("Errore invio."), backgroundColor: Colors.red));
                        }
                      }
                    },
                    child: Text(isDialogUploading ? "..." : "Invia"),
                  ),
                ],
              );
            }
        );
      },
    );
  }
}

class _PinClipper extends CustomClipper<Path> {
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
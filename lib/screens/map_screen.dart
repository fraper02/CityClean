import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../components/bottom_nav_bar.dart';
// import '../models/map_models.dart'; // Rimosso temporaneamente se non usato per i report
import '../services/report_service.dart';
import '../services/storage_service.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // --- SERVIZI ---
  // Abbiamo mantenuto solo il servizio essenziale per le segnalazioni
  final ReportService _reportService = ReportService();

  // --- STATO ---
  LatLng _currentCenter = const LatLng(40.6795, 14.7645); // Default Salerno
  bool _isLocationLoaded = false;
  bool _isLoading = false;

  // Liste dati
  List<Map<String, dynamic>> _reports = []; // Manteniamo solo i report per ora

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  // --- 1. GEOLOCALIZZAZIONE ---
  Future<void> _initializeLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _loadPoints(); // Se GPS spento, carica comunque i dati sulla posizione di default
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

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 10));

      if (mounted) {
        setState(() {
          _currentCenter = LatLng(position.latitude, position.longitude);
          _isLocationLoaded = true;
        });
        _mapController.move(_currentCenter, 15.0);
        _loadPoints(); // Carica i dati dopo aver trovato la posizione
      }
    } catch (e) {
      debugPrint("Errore GPS: $e");
      _loadPoints();
    }
  }

  // --- 2. RICERCA / CARICAMENTO DATI ---
  Future<void> _loadPoints() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      debugPrint("Avvio caricamento Report da DB...");

      // Carichiamo SOLO i report per semplificare il debug
      final reports = await _reportService.getReports();

      if (!mounted) return;

      setState(() {
        _reports = reports;
      });

      debugPrint("Caricati ${_reports.length} report.");

    } catch (e) {
      debugPrint("Errore caricamento dati mappa: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Errore DB: $e"), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- 3. SEGNALAZIONE RAPIDA (HUD) ---
  void _showQuickReportDialog(BuildContext context) async {
    final userId = await StorageService.getUserId();
    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Errore: Utente non loggato")));
      }
      return;
    }

    final reportDescController = TextEditingController();
    LatLng? reportLocation = _isLocationLoaded ? _currentCenter : null;
    File? selectedImage;
    bool isUploading = false;
    final ImagePicker picker = ImagePicker();

    String selectedPollutionLevel = 'Medio';
    final List<String> pollutionOptions = ['Basso', 'Medio', 'Alto', 'Critico'];

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
            builder: (context, setState) {

              Future<void> pickImage(ImageSource source) async {
                final XFile? photo = await picker.pickImage(source: source, imageQuality: 50);
                if (photo != null) {
                  setState(() {
                    selectedImage = File(photo.path);
                  });
                }
              }

              return AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 10),
                    Text("Segnalazione"),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => pickImage(ImageSource.camera),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            image: selectedImage != null
                                ? DecorationImage(image: FileImage(selectedImage!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: selectedImage == null
                              ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: reportDescController,
                        decoration: const InputDecoration(labelText: "Descrizione", border: OutlineInputBorder()),
                        maxLines: 2,
                      ),
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
                    onPressed: isUploading ? null : () async {
                      if (reportDescController.text.isEmpty) return;

                      // Recupero posizione fresca se serve
                      if (reportLocation == null) {
                        try {
                          Position p = await Geolocator.getCurrentPosition();
                          reportLocation = LatLng(p.latitude, p.longitude);
                        } catch (e) {
                          // Fallback su centro mappa se GPS fallisce nel dialog
                          reportLocation = _currentCenter;
                        }
                      }

                      setState(() => isUploading = true);

                      try {
                        String? imageId;
                        if (selectedImage != null) {
                          imageId = await _reportService.uploadImageAndGetId(selectedImage!);
                        }

                        await _reportService.createReport(
                          description: reportDescController.text,
                          wasteType: "Rapida",
                          pollutionLevel: selectedPollutionLevel,
                          latitude: reportLocation!.latitude,
                          longitude: reportLocation!.longitude,
                          userId: userId,
                          imageId: imageId,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inviato!")));
                          _loadPoints(); // Ricarica la mappa
                        }
                      } catch (e) {
                        setState(() => isUploading = false);
                        debugPrint("Errore invio: $e");
                      }
                    },
                    child: Text(isUploading ? "..." : "Invia"),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 0),
      body: Stack(
        children: [
          // --- 4. MAPPA ---
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

              // LAYER SEGNALAZIONI (Unico layer dati rimasto)
              MarkerLayer(
                markers: _reports.map((report) {
                  final lat = report['latitudine'] as double? ?? 0.0;
                  final lng = report['longitudine'] as double? ?? 0.0;
                  return Marker(
                    point: LatLng(lat, lng),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showReportDetails(report),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: const Icon(Icons.priority_high, color: Colors.white, size: 24),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // LAYER UTENTE
              if (_isLocationLoaded)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentCenter,
                      width: 25,
                      height: 25,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.3),
                          border: Border.all(color: Colors.blue, width: 3),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // --- HUD HEADER ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              // height: 160, // RIMOSSO: Evita l'overflow su schermi con notch grandi
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.95),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
              ),
              child: SafeArea(
                bottom: false, // Non serve padding safe area sotto
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20), // Padding interno
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Si adatta al contenuto
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Mappa Segnalazioni", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 5),
                      Text("Report attivi: ${_reports.length}", style: const TextStyle(fontSize: 16, color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- HUD TASTO SEGNALA ---
          Positioned(
            top: 150, // Potrebbe dover essere aggiustato dinamicamente, ma per ora lo lasciamo fisso o lo ancoriamo in basso
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () => _showQuickReportDialog(context),
              icon: const Icon(Icons.add_alert, size: 20, color: Colors.white),
              label: const Text("Nuova Segnalazione", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
              ),
            ),
          ),

          // --- HUD TASTO CERCA ---
          Positioned(
            top: 200,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _loadPoints,
              icon: _isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2))
                  : const Icon(Icons.refresh, color: Colors.green),
              label: Text(_isLoading ? "Caricamento..." : "Aggiorna Mappa"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
              ),
            ),
          ),

          // --- HUD GPS FAB ---
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              heroTag: "gps_fab",
              onPressed: _initializeLocation,
              backgroundColor: primaryGreen,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Helper per mostrare dettagli marker (Semplificato)
  void _showReportDetails(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Dettaglio Segnalazione"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Livello: ${report['livelloinquinamento'] ?? 'N/A'}"),
            const SizedBox(height: 5),
            Text("Descrizione: ${report['descrizione'] ?? 'Nessuna descrizione'}"),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Chiudi"))],
      ),
    );
  }
}
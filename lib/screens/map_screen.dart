import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../components/bottom_nav_bar.dart';
import '../models/map_models.dart';
import '../services/osm_service.dart';
import '../services/report_service.dart';
import '../services/storage_service.dart';
import 'dart:async';
import '../data/map_data.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();

}

class _MapScreenState extends State<MapScreen> {
  void _showStoreDetails(AffiliatedStore store) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              child: Image.network(
                store.imageUrl,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.store, size: 50, color: Colors.grey)),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NOME
                  Text(
                    store.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Orari: ${store.openHours}",
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Chiudi"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  final MapController _mapController = MapController();
  final OsmService _osmService = OsmService();
  final ReportService _reportService = ReportService();

  LatLng _currentCenter = const LatLng(40.6795, 14.7645);
  bool _isLocationLoaded = false;

  List<EcoPoint> _ecoPoints = [];
  List<PollutedZone> _pollutedZones = [];
  List<Map<String, dynamic>> _reports = []; // Lista per le segnalazioni

  // Lista dei negozi associati
  final List<AffiliatedStore> _stores = [
    AffiliatedStore(
      name: "Centro Commerciale Le Cotoniere",
      location: const LatLng(40.7039561, 14.7766496),
      openHours: "10:00 - 21:00",
      imageUrl: "https://th.bing.com/th/id/OIP.pz8O-CNwViydgfwsn7D1FQHaEK?w=293&h=180&c=7&r=0&o=7&dpr=1.1&pid=1.7&rm=3",
    ),
    AffiliatedStore(
      name: "Unieuro",
      location: const LatLng(40.6514007, 14.8212368),
      openHours: "09:00 - 20:30",
      imageUrl: "https://iportaliweb.it/wp-content/uploads/2022/08/unieuro-768x490.png",
    ),
    AffiliatedStore(
      name: "Supermercato etè",
      location: const LatLng(40.6633147, 14.7945714),
      openHours: "08:00 - 14:00 / 15:00 - 20:30",
      imageUrl: "https://tse4.mm.bing.net/th/id/OIP.1A2buJX0N_sTwMQYdVPmJQHaEL?rs=1&pid=ImgDetMain&o=7&rm=3",
    ),
    AffiliatedStore(
      name: "The Space Cinema",
      location: const LatLng(40.6471238, 14.8166512),
      openHours: "13:00 - 23:00",
      imageUrl: "https://th.bing.com/th/id/OIP.tuqxik_9HroDY_hmQWyi5gAAAA?o=7&cb=ucfimg2&rm=3&ucfimg=1&rs=1&pid=ImgDetMain&o=7&rm=3",
    ),
    AffiliatedStore(
      name: "Bar Gelateria Nettuno",
      location: const LatLng(40.6691654, 14.7901217),
      openHours: "06:00 - 01:00",
      imageUrl: "https://th.bing.com/th/id/R.5384a56c0be5170469b970de51ebbba4?rik=Iexp5NJ3LsC59A&pid=ImgRaw&r=0",
    ),
    AffiliatedStore(
      name: "Chiosco della Musica",
      location: const LatLng(40.6755, 14.7933),
      openHours: "09:00 - 20:00",
      imageUrl: "https://th.bing.com/th/id/OIP.ZQagfDB_FZ2HiCZpDybY9wHaHa?o=7&cb=ucfimg2&rm=3&ucfimg=1&rs=1&pid=ImgDetMain&o=7&rm=3",
    ),
    AffiliatedStore(
      name: "Sole365",
      location: const LatLng(40.6754715, 14.7773649),
      openHours: "mercoledì,07–22\n"
          "giovedì,07–22\n"
          "venerdì,07–22\n"
          "sabato,07–22\n"
          "domenica,08–22\n"
          "lunedì,07–22\n"
          "martedì,07–22\n",
      imageUrl: "https://lh3.googleusercontent.com/gps-cs-s/AG0ilSw2zmkkVlWl6ROpX-pl47hafV6B8GhiAGMjzsK82rWTKS3xMHTQm5rvkemoCOzKBFwC4_8I0x_2p8CtaeRhl7tua2KmdZLhSsc5ZFjrhqB0jNQKl3lVdimc-gQZNZzRb8sJ_pwq=w408-h306-k-no",
    ),
  ];
  bool _isLoading = false;
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

    await Future.delayed(const Duration(seconds: 1));

    try {
      final zones = MockMapData.pollutedZones;
      final mockPoints = MockMapData.ecoPoints;

      LatLng centerToUse = _currentCenter;
      try {
        centerToUse = _mapController.camera.center;
      } catch(_) {}

      final realPoints = await _osmService.fetchRecyclingPoints(centerToUse, 2000);
      final reports = await _reportService.getReports(); // Carica le segnalazioni

      if (mounted) {
        setState(() {
          _pollutedZones = zones;
          _ecoPoints = [...mockPoints, ...realPoints];
          _reports = reports;
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

  // --- FUNZIONE PER IL POPUP SEGNALAZIONE RAPIDA ---
  void _showQuickReportDialog(BuildContext context) async {
    final userId = await StorageService.getUserId();
    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Errore: Utente non loggato")));
      }
      return;
    }

    final reportDescController = TextEditingController();
    String reportLocationStatus = "Posizione attuale";
    LatLng? reportLocation = _isLocationLoaded ? _currentCenter : null;
    File? selectedImage;
    bool isUploading = false;
    final ImagePicker picker = ImagePicker();

    // Variabile per il livello di inquinamento
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
                    Text("Segnalazione Rapida"),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Scatta una foto e segnala rifiuti abbandonati qui.", style: TextStyle(fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 15),

                      GestureDetector(
                        onTap: () => pickImage(ImageSource.camera),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey[400]!),
                            image: selectedImage != null
                                ? DecorationImage(image: FileImage(selectedImage!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: selectedImage == null
                              ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                              Text("Scatta foto (Opzionale)", style: TextStyle(color: Colors.grey)),
                            ],
                          )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 15),

                      TextField(
                        controller: reportDescController,
                        decoration: const InputDecoration(
                          labelText: "Descrizione Rifiuti",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 15),

                      // --- MENU A TENDINA LIVELLO INQUINAMENTO ---
                      DropdownButtonFormField<String>(
                        initialValue: selectedPollutionLevel,
                        decoration: const InputDecoration(
                          labelText: "Livello Inquinamento",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.bar_chart),
                        ),
                        items: pollutionOptions.map((String val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          if (newVal != null) {
                            setState(() {
                              selectedPollutionLevel = newVal;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.green),
                          const SizedBox(width: 5),
                          Expanded(child: Text(reportLocation != null ? "GPS: ${reportLocation!.latitude.toStringAsFixed(4)}, ${reportLocation!.longitude.toStringAsFixed(4)}" : "Posizione sconosciuta", style: const TextStyle(fontSize: 12))),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: isUploading ? null : () async {
                      if (reportDescController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inserisci descrizione")));
                        return;
                      }
                      if (reportLocation == null) {
                        // Prova a recuperare posizione se mancante
                        try {
                          Position p = await Geolocator.getCurrentPosition();
                          reportLocation = LatLng(p.latitude, p.longitude);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Impossibile recuperare posizione")));
                          return;
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
                          pollutionLevel: selectedPollutionLevel, // Passiamo il valore selezionato
                          latitude: reportLocation!.latitude,
                          longitude: reportLocation!.longitude,
                          userId: userId,
                          imageId: imageId,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Segnalazione inviata!")));
                          // Ricarica i punti dopo l'invio
                          _loadPoints();
                        }
                      } catch (e) {
                        setState(() => isUploading = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore: $e")));
                        }
                      }
                    },
                    child: Text(isUploading ? "Invio..." : "Invia"),
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
    final pointsToShow = _showBins ? _ecoPoints : _ecoPoints.where((p) => p.type != 'Cestino').toList();

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
                circles: _pollutedZones.map((zone) => CircleMarker(
                  point: zone.center,
                  radius: zone.radius,
                  useRadiusInMeter: true,
                  color: Colors.red.withOpacity(0.3),
                  borderColor: Colors.red.withOpacity(0.7),
                  borderStrokeWidth: 2,
                )).toList(),
              ),
              // LAYER SEGNALAZIONI DATABASE
              MarkerLayer(
                markers: _reports.map((report) {
                  final lat = report['latitudine'] as double? ?? 0.0;
                  final lng = report['longitudine'] as double? ?? 0.0;
                  return Marker(
                    point: LatLng(lat, lng),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Row(
                              children: [
                                Icon(Icons.report_problem, color: Colors.red),
                                SizedBox(width: 8),
                                Text("Dettagli Segnalazione", style: TextStyle(fontSize: 18)),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(Icons.bar_chart, "Livello Inquinamento", report['livelloinquinamento'] ?? 'N/A'),
                                const SizedBox(height: 10),
                                _buildInfoRow(Icons.description, "Tipo Inquinamento", report['tipoinquinamento'] ?? 'N/A'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Chiudi"),
                              )
                            ],
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.priority_high,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              MarkerLayer(
                markers: pointsToShow.map((point) => Marker(
                  point: point.location,
                  width: 50,
                  height: 60,
                  child: _buildCustomEcoMarker(point),
                )).toList(),
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
              MarkerLayer(
                markers: _stores.map((store) {
                  return Marker(
                    point: store.location,
                    width: 45, // Grandezza del pallino
                    height: 45,
                    child: GestureDetector(
                      onTap: () => _showStoreDetails(store), // Apre i dettagli al click
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.purple, // Colore distintivo
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                          ],
                        ),
                        child: const Icon(
                          Icons.storefront, // Icona Negozio
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // HEADER
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.95),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Mappa", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 5),
                      const Text("Salerno - Trova punti di interesse", style: TextStyle(fontSize: 16, color: Colors.white70)),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 14),
                          const SizedBox(width: 5),
                          Text("Punti visibili: ${pointsToShow.length}", style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // SEGNALA RIFIUTI BUTTON
          Positioned(
            top: 190,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () => _showQuickReportDialog(context),
              icon: const Icon(Icons.warning_amber_rounded, size: 20, color: Colors.red),
              label: const Text("Segnala rifiuti", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
              ),
            ),
          ),

          // REFRESH BUTTON (Moved down)
          Positioned(
            top: 245,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _loadPoints,
              icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2)) : const Icon(Icons.refresh, color: Colors.green),
              label: Text(_isLoading ? "Caricamento..." : "Cerca qui"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
              ),
            ),
          ),

          // SWITCH CESTINI
          Positioned(
            bottom: 30,
            left: 20,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, color: _showBins ? Colors.orange[700] : Colors.grey, size: 24),
                  const SizedBox(width: 8),
                  const Text("Cestini", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(width: 5),
                  Switch(
                    value: _showBins,
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.orange[400],
                    inactiveThumbColor: Colors.grey[50],
                    inactiveTrackColor: Colors.grey[300],
                    onChanged: (val) => setState(() => _showBins = val),
                  ),
                ],
              ),
            ),
          ),

          // FAB GPS (Spostato in alto rispetto al nuovo FAB)
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
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
            width: double.infinity,
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
                    minimumSize: const Size(double.infinity, 50),
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
          ClipPath(
            clipper: _MarkerClipper(),
            child: Container(width: 15, height: 10, color: iconColor),
          ),
        ],
      ),
    );
  }
}

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
class AffiliatedStore {
  final String name;
  final LatLng location;
  final String openHours;
  final String imageUrl;

  AffiliatedStore({
    required this.name,
    required this.location,
    required this.openHours,
    required this.imageUrl,
  });
}
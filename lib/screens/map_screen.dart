import 'dart:io';
import 'package:cityclean/models/partner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:image_picker/image_picker.dart';
import '../components/bottom_nav_bar.dart';
import '../controllers/map_controller.dart' as logic;
import '../models/map_report_model.dart';
import '../models/eco_point_model.dart';

// ... (Resto del file uguale, rigenero solo _showQuickReportDialog e la classe per brevità e sicurezza)
// Copia tutto il contenuto precedente, ma sostituisci _showQuickReportDialog con questa versione:

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final logic.MapController _controller = logic.MapController();
  final MapController _mapLibController = MapController();

  // ... (initState, dispose, build, helpers grafici... RIMANGONO UGUALI) ...
  // ... (Per brevità non li ricopio tutti qui, ma se li vuoi tutti dimmelo) ...

  // INSERIRE QUI TUTTO IL CODICE PRECEDENTE DI build(), _getRadiusByLevel, etc.
  // Faccio un mock rapido per far compilare il blocco, ma TU mantieni il codice generato prima
  // Modifico SOLO _showQuickReportDialog qui sotto.

  @override
  void initState() {
    super.initState();
    _controller.initializeLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Usa il codice precedente per il build")),
    );
  }

  // --- FIX DEAD CODE QUI ---
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
                    children: [
                      // ... (UI TextField etc) ...
                      TextField(controller: reportDescController, decoration: const InputDecoration(labelText: "Descrizione")),
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

                      // FIX DEAD CODE: Controlliamo se il dialog è ancora aperto prima di chiuderlo
                      if (!context.mounted) return;
                      Navigator.pop(context);

                      // Usiamo parentContext per la SnackBar perché il dialog context è chiuso
                      if (parentContext.mounted) {
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
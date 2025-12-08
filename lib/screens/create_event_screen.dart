import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:cityclean/services/report_service.dart';
import 'package:cityclean/screens/location_picker_screen.dart';

class CreateEventScreen extends StatefulWidget {
  final String userId;
  final String? groupName;

  const CreateEventScreen({super.key, required this.userId, this.groupName});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final ReportService _reportService = ReportService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _wasteTypeController = TextEditingController();
  
  DateTime _eventDate = DateTime.now();
  LatLng? _eventLocation;
  String _locationStatus = "Nessuna posizione selezionata";
  bool _isSubmitting = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _eventDate = picked;
      });
    }
  }

  Future<void> _useGps() async {
    setState(() => _locationStatus = "Ricerca GPS...");
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("GPS disattivato");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception("Permesso GPS negato");
      }

      Position pos = await Geolocator.getCurrentPosition();
      setState(() {
        _eventLocation = LatLng(pos.latitude, pos.longitude);
        _locationStatus = "Posizione GPS acquisita";
      });
    } catch (e) {
      setState(() => _locationStatus = "Errore GPS: $e");
    }
  }

  Future<void> _pickFromMap() async {
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const LocationPickerScreen())
    );
    if (result != null && result is LatLng) {
      setState(() {
        _eventLocation = result;
        _locationStatus = "Posizione da Mappa selezionata";
      });
    }
  }

  Future<void> _submitEvent() async {
    if (_titleController.text.isEmpty || _eventLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Titolo e Posizione sono obbligatori!")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      groupName: widget.groupName;
      await _reportService.createEvent(
        title: _titleController.text,
        description: _descController.text,
        wasteType: _wasteTypeController.text,
        date: _eventDate,
        latitude: _eventLocation!.latitude,
        longitude: _eventLocation!.longitude,
        userId: widget.userId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Evento creato con successo!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Segnala Evento Futuro"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Organizza una pulizia di gruppo",
              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),

            // Titolo
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Titolo Evento",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 15),

            // Descrizione
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: "Descrizione",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 15),

            // Tipologia Rifiuti
            TextField(
              controller: _wasteTypeController,
              decoration: const InputDecoration(
                labelText: "Tipologia Rifiuti Prevista",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 20),

            // Data
            const Text("Data Evento", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text(DateFormat('dd/MM/yyyy').format(_eventDate), style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Posizione
            const Text("Posizione", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Text(_locationStatus, style: TextStyle(color: _eventLocation != null ? Colors.green : Colors.grey)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _useGps,
                    icon: const Icon(Icons.my_location),
                    label: const Text("Usa GPS"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue[700],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickFromMap,
                    icon: const Icon(Icons.map),
                    label: const Text("Scegli su Mappa"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[50],
                      foregroundColor: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Bottone Invio
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("INVIA SEGNALAZIONE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.green[700],
            colorScheme: ColorScheme.light(primary: Colors.green[700]!),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _eventDate = picked;
      });
    }
  }

  Future<void> _pickFromMap() async {
    if (!mounted) return;

    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );

    if (result != null) {
      setState(() {
        _eventLocation = result;
        _locationStatus = "Posizione selezionata: \n${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}";
      });
    }
  }

  Future<void> _submitEvent() async {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        _wasteTypeController.text.isEmpty ||
        _eventLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compila tutti i campi e seleziona una posizione."), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _reportService.createEvent(
        userId: widget.userId,
        title: _titleController.text,
        description: _descController.text,
        wasteType: _wasteTypeController.text,
        date: _eventDate,
        latitude: _eventLocation!.latitude,
        longitude: _eventLocation!.longitude,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Evento creato con successo!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // 1. HEADER VERDE (SliverAppBar)
          // Si comprime quando scorri, il contenuto scorre sotto di esso.
          SliverAppBar(
            pinned: true,
            expandedHeight: 240.0,
            backgroundColor: Colors.green[700],
            elevation: 0,
            leading: IconButton(
              key: const Key('btn_back_create_event'), // ID TEST
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              collapseMode: CollapseMode.parallax,
              title: const Text(
                "Organizza Evento",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[800]!, Colors.green[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.event_available_rounded, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      if (widget.groupName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Per il gruppo: ${widget.groupName}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. CONTENUTO SCORREVOLE (Sotto l'header)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Dettagli Generali", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 15),

                  Semantics(
                    identifier: 'titleField',
                    child: _buildTextField(
                      key: const Key('input_event_title'), // ID TEST
                      controller: _titleController,
                      label: "Titolo Evento",
                      icon: Icons.title,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Semantics(
                    identifier: 'descField',
                    child: _buildTextField(
                      key: const Key('input_event_desc'), // ID TEST
                      controller: _descController,
                      label: "Descrizione",
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Semantics(
                    identifier: 'catField',
                    child: _buildTextField(
                      key: const Key('input_event_waste'), // ID TEST
                      controller: _wasteTypeController,
                      label: "Tipo di Rifiuti (es. Plastica)",
                      icon: Icons.category_outlined,
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),

                  const Text("Logistica", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 15),

                  // DATA PICKER TILE
                  Semantics(
                    identifier: 'dateButton',
                    child: _buildActionTile(
                      key: const Key('btn_pick_date'), // ID TEST
                      icon: Icons.calendar_month_rounded,
                      iconColor: Colors.blue,
                      title: "Data dell'evento",
                      subtitle: DateFormat('dd/MM/yyyy').format(_eventDate),
                      onTap: _pickDate,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // LOCATION PICKER TILE
                  Semantics(
                    identifier: 'pickFromMapButton',
                    child: _buildActionTile(
                      key: const Key('btn_pick_location'), // ID TEST
                      icon: Icons.map_rounded,
                      iconColor: Colors.orange,
                      title: "Posizione",
                      subtitle: _eventLocation == null ? "Tocca per scegliere" : "Posizione Selezionata",
                      isSelected: _eventLocation != null,
                      onTap: _pickFromMap,
                    ),
                  ),

                  if (_eventLocation != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            "Coordinate: ${_eventLocation!.latitude.toStringAsFixed(3)}, ${_eventLocation!.longitude.toStringAsFixed(3)}",
                            style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 40),

                  // SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: Semantics(
                      identifier: 'submitButton',
                      child: ElevatedButton(
                        key: const Key('btn_submit_event'), // ID TEST
                        onPressed: _isSubmitting ? null : _submitEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: Colors.green.withOpacity(0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded),
                            SizedBox(width: 10),
                            Text("PUBBLICA EVENTO", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40), // Spazio extra in fondo per lo scroll
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget per i campi di testo
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Key? key,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: TextFormField(
        key: key,
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green[700]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  // Helper Widget per le "Tile" cliccabili
  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Key? key,
    bool isSelected = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
        border: isSelected ? Border.all(color: Colors.green, width: 1.5) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: key,
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:cityclean/models/event.dart';
import 'package:cityclean/services/admin/admin_events_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color adminPrimaryColor = Color(0xFF2E7D32);

class AdminEditEventPage extends StatefulWidget {
  final Event? event;

  const AdminEditEventPage({super.key, this.event});

  @override
  State<AdminEditEventPage> createState() => _AdminEditEventPageState();
}

class _AdminEditEventPageState extends State<AdminEditEventPage> {
  final _formKey = GlobalKey<FormState>();
  final AdminEventsService _service = AdminEventsService();

  late TextEditingController _titoloController;
  late TextEditingController _descrizioneController;
  late TextEditingController _localitaController;
  late TextEditingController _categoriaController;
  late TextEditingController _immagineController;
  DateTime? _dataInizio;
  DateTime? _dataFine;

  bool get isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    _titoloController = TextEditingController(text: widget.event?.titolo ?? '');
    _descrizioneController = TextEditingController(text: widget.event?.descrizione ?? '');
    _localitaController = TextEditingController(text: widget.event?.localita ?? '');
    _categoriaController = TextEditingController(text: widget.event?.categoria ?? '');
    _immagineController = TextEditingController(text: widget.event?.immagine ?? '');
    _dataInizio = widget.event?.dataOraInizio;
    _dataFine = widget.event?.dataOraFine;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _dataInizio : _dataFine) ?? DateTime.now(),
      firstDate: DateTime(2020), 
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: adminPrimaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context, 
        initialTime: TimeOfDay.fromDateTime((isStartDate ? _dataInizio : _dataFine) ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          final fullDate = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
          if (isStartDate) {
            _dataInizio = fullDate;
          } else {
            _dataFine = fullDate;
          }
        });
      }
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final eventData = {
        'titolo': _titoloController.text,
        'descrizione': _descrizioneController.text,
        'localita': _localitaController.text,
        'categoria': _categoriaController.text,
        'immagine': _immagineController.text,
        'dataorainizio': _dataInizio?.toIso8601String(),
        'dataorafine': _dataFine?.toIso8601String(),
      };

      try {
        if (isEditing) {
          await _service.updateEvent(widget.event!.id, eventData);
        } else {
          eventData['idevento'] = 'evt_${DateTime.now().millisecondsSinceEpoch}';
          await _service.createEvent(eventData);
        }
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifica Evento' : 'Crea Evento'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_titoloController, 'Titolo', icon: Icons.title),
              _buildTextField(_descrizioneController, 'Descrizione', maxLines: 4, icon: Icons.description),
              const SizedBox(height: 16),
              _buildTextField(_localitaController, 'Località', icon: Icons.location_on),
              _buildTextField(_categoriaController, 'Categoria', icon: Icons.category),
              _buildTextField(_immagineController, 'URL Immagine', icon: Icons.image),
              const SizedBox(height: 24),
              _buildDatePicker('Data Inizio', _dataInizio, () => _selectDate(context, true)),
              const SizedBox(height: 16),
              _buildDatePicker('Data Fine', _dataFine, () => _selectDate(context, false)),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: Icon(isEditing ? Icons.save : Icons.add, color: Colors.white),
                label: Text(isEditing ? 'Salva Modifiche' : 'Crea Evento'),
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: adminPrimaryColor,
                  foregroundColor: Colors.white, 
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: adminPrimaryColor, width: 2),
          ),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Questo campo è obbligatorio' : null,
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onPressed) {
    return Material(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: adminPrimaryColor),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 4),
                  Text(
                    date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : 'Non impostata',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

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
          // Per creare un nuovo evento, dobbiamo fornire un id univoco.
          // Usiamo una combinazione di testo e timestamp per semplicità.
          eventData['idevento'] = 'evt_${DateTime.now().millisecondsSinceEpoch}';
          await _service.createEvent(eventData);
        }
        if (mounted) {
          Navigator.pop(context, true); // Ritorna true per indicare che la lista va aggiornata
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_titoloController, 'Titolo'),
              _buildTextField(_descrizioneController, 'Descrizione', maxLines: 3),
              _buildTextField(_localitaController, 'Località'),
              _buildTextField(_categoriaController, 'Categoria'),
              _buildTextField(_immagineController, 'URL Immagine'),
              const SizedBox(height: 20),
              _buildDatePicker('Data Inizio', _dataInizio, () => _selectDate(context, true)),
              _buildDatePicker('Data Fine', _dataFine, () => _selectDate(context, false)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: adminPrimaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(isEditing ? 'Salva Modifiche' : 'Crea Evento'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (value) => (value == null || value.isEmpty) ? 'Questo campo è obbligatorio' : null,
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onPressed) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(label),
        subtitle: Text(date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : 'Non impostata'),
        trailing: const Icon(Icons.calendar_today, color: adminPrimaryColor),
        onTap: onPressed,
      ),
    );
  }
}

import 'package:cityclean/controllers/admin/ecopoints_controller.dart';
import 'package:cityclean/models/eco_point_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AdminListEcopointsPage extends StatefulWidget {
  const AdminListEcopointsPage({super.key});

  @override
  AdminListEcopointsPageState createState() => AdminListEcopointsPageState();
}

class AdminListEcopointsPageState extends State<AdminListEcopointsPage> {
  late final EcopointsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EcopointsController();
    _controller.loadEcopoints();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Metodo pubblico richiamato dalla Dashboard tramite GlobalKey
  void refreshEcopoints() {
    _controller.loadEcopoints();
  }

  void _openEcopointDialog([Ecopoint? ecopoint]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _EcopointDialog(
        controller: _controller,
        ecopoint: ecopoint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Rimossi i pulsanti (actions) dall'AppBar locale per usare quelli della Dashboard
      appBar: AppBar(
        title: const Text("Gestione Ecopunti"),
      ),
      body: ValueListenableBuilder<EcopointsState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          if (state == EcopointsState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state == EcopointsState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(_controller.errorMessage.value, textAlign: TextAlign.center),
                  ElevatedButton(onPressed: _controller.loadEcopoints, child: const Text("Riprova"))
                ],
              ),
            );
          }

          return ValueListenableBuilder<List<Ecopoint>>(
            valueListenable: _controller.ecopoints,
            builder: (context, ecopoints, _) {
              if (ecopoints.isEmpty) {
                return const Center(child: Text("Nessun ecopunto trovato."));
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                itemCount: ecopoints.length,
                itemBuilder: (context, index) {
                  return _buildEcopointCard(ecopoints[index]);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEcopointDialog(null),
        backgroundColor: Colors.green[700],
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text("Nuovo Ecopunto", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEcopointCard(Ecopoint ecopoint) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
          child: Icon(Icons.recycling, color: Colors.green[700]),
        ),
        title: Text(ecopoint.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(ecopoint.address, maxLines: 1, overflow: TextOverflow.ellipsis),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                _buildStatRow(Icons.map, "Coordinate", "${ecopoint.latitude.toStringAsFixed(4)}, ${ecopoint.longitude.toStringAsFixed(4)}"),
                _buildStatRow(Icons.category, "Tipologia", ecopoint.type),
                const SizedBox(height: 10),
                const Text("Statistiche Mensili", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                _buildStatRow(Icons.delete_outline, "Conferimenti", ecopoint.monthlyConferimentiCount.toString()),
                _buildStatRow(Icons.group, "Utenti", ecopoint.monthlyUniqueUsers.toString()),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text("Modifica"),
                      onPressed: () => _openEcopointDialog(ecopoint),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      label: const Text("Elimina", style: TextStyle(color: Colors.red)),
                      onPressed: () => _showDeleteDialog(context, ecopoint),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[500], size: 16),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(color: Colors.grey)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Ecopoint ecopoint) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Elimina Ecopunto"),
        content: Text("Sei sicuro di voler eliminare '${ecopoint.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _controller.deleteEcopoint(context, ecopoint.id);
            },
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// NUOVO WIDGET DIALOG: Isola lo stato e il contesto, risolvendo i problemi CI/CD
// --------------------------------------------------------------------------
class _EcopointDialog extends StatefulWidget {
  final EcopointsController controller;
  final Ecopoint? ecopoint;

  const _EcopointDialog({required this.controller, this.ecopoint});

  @override
  State<_EcopointDialog> createState() => _EcopointDialogState();
}

class _EcopointDialogState extends State<_EcopointDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _typeController;
  late TextEditingController _latController;
  late TextEditingController _lonController;
  bool _isSaving = false;

  bool get _isCreating => widget.ecopoint == null;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: _isCreating ? '' : widget.ecopoint!.id);
    _nameController = TextEditingController(text: widget.ecopoint?.name ?? '');
    _addressController = TextEditingController(text: widget.ecopoint?.address ?? '');
    _typeController = TextEditingController(text: widget.ecopoint?.type ?? 'Generico');
    _latController = TextEditingController(text: widget.ecopoint?.latitude.toString() ?? '');
    _lonController = TextEditingController(text: widget.ecopoint?.longitude.toString() ?? '');
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _typeController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    double startLat = double.tryParse(_latController.text.replaceAll(',', '.')) ?? 40.6824;
    double startLng = double.tryParse(_lonController.text.replaceAll(',', '.')) ?? 14.7681;

    final LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => _LocationPickerScreen(initialCenter: LatLng(startLat, startLng)),
      ),
    );

    if (pickedLocation != null) {
      _latController.text = pickedLocation.latitude.toStringAsFixed(6);
      _lonController.text = pickedLocation.longitude.toStringAsFixed(6);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // REFERENCE CAPTURE: Catturiamo le referenze PRIMA dell'operazione asincrona.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final double lat = double.parse(_latController.text.replaceAll(',', '.'));
      final double lon = double.parse(_lonController.text.replaceAll(',', '.'));

      String newId = '';
      if (_isCreating) {
        newId = 'ECO-${DateTime.now().millisecondsSinceEpoch}-${(lat * 100).toInt()}';
      }

      final ecopointData = Ecopoint(
        id: _isCreating ? newId : _idController.text,
        name: _nameController.text,
        address: _addressController.text,
        type: _typeController.text,
        latitude: lat,
        longitude: lon,
      );

      if (_isCreating) {
        await widget.controller.createEcopoint(context, ecopointData);
      } else {
        await widget.controller.updateEcopoint(context, ecopointData);
      }

      navigator.pop();

    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text("Errore: $e")));
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isCreating ? "Nuovo Ecopunto" : "Modifica Ecopunto"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isCreating)
                TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(labelText: 'ID (Sola Lettura)', filled: true),
                  readOnly: true,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              if (_isCreating)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text("ID verrà generato automaticamente: ECO-...", style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                ),
              const SizedBox(height: 10),
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome Punto'), validator: (v) => v!.isEmpty ? 'Inserisci un nome' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Indirizzo')),
              const SizedBox(height: 10),
              TextFormField(controller: _typeController, decoration: const InputDecoration(labelText: 'Tipologia')),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickLocation,
                icon: const Icon(Icons.map),
                label: const Text("📍 Seleziona su Mappa"),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _latController, decoration: const InputDecoration(labelText: 'Lat'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(controller: _lonController, decoration: const InputDecoration(labelText: 'Lon'), keyboardType: TextInputType.number)),
                ],
              )
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            child: const Text('Annulla')
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : Text(_isCreating ? 'Crea' : 'Salva'),
        ),
      ],
    );
  }
}

class _LocationPickerScreen extends StatefulWidget {
  final LatLng initialCenter;
  const _LocationPickerScreen({required this.initialCenter});
  @override
  State<_LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<_LocationPickerScreen> {
  late LatLng _pickedPosition;
  final MapController _mapController = MapController();

  @override
  void initState() { super.initState(); _pickedPosition = widget.initialCenter; }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seleziona Posizione"), actions: [IconButton(icon: const Icon(Icons.check), onPressed: () => Navigator.pop(context, _pickedPosition))]),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: widget.initialCenter, initialZoom: 15, onTap: (_, p) => setState(() => _pickedPosition = p)),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.unisa.cityclean'),
              MarkerLayer(markers: [Marker(point: _pickedPosition, width: 50, height: 50, child: const Icon(Icons.location_on, color: Colors.red, size: 40))]),
            ],
          ),
          Positioned(
            bottom: 30, left: 20, right: 20,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _pickedPosition),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
              child: const Text("CONFERMA POSIZIONE", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
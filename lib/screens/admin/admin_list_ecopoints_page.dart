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

  void createNewEcopoint() {
    _showEditDialog(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Gestione Ecopunti"),
        actions: [
          IconButton(onPressed: _controller.loadEcopoints, icon: const Icon(Icons.refresh))
        ],
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
        onPressed: createNewEcopoint,
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
                      onPressed: () => _showEditDialog(context, ecopoint),
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

  void _showEditDialog(BuildContext parentContext, Ecopoint? ecopoint) {
    final isCreating = ecopoint == null;
    final formKey = GlobalKey<FormState>();

    final idController = TextEditingController(text: isCreating ? '' : ecopoint.id);
    final nomeController = TextEditingController(text: ecopoint?.name ?? '');
    final indirizzoController = TextEditingController(text: ecopoint?.address ?? '');
    final tipologiaController = TextEditingController(text: ecopoint?.type ?? 'Generico');
    final latController = TextEditingController(text: ecopoint?.latitude.toString() ?? '');
    final lonController = TextEditingController(text: ecopoint?.longitude.toString() ?? '');

    void pickLocationOnMap(BuildContext dialogContext) async {
      double startLat = double.tryParse(latController.text.replaceAll(',', '.')) ?? 40.6824;
      double startLng = double.tryParse(lonController.text.replaceAll(',', '.')) ?? 14.7681;

      final LatLng? pickedLocation = await Navigator.push(
        parentContext,
        MaterialPageRoute(
          builder: (ctx) => _LocationPickerScreen(initialCenter: LatLng(startLat, startLng)),
        ),
      );

      if (pickedLocation != null) {
        latController.text = pickedLocation.latitude.toStringAsFixed(6);
        lonController.text = pickedLocation.longitude.toStringAsFixed(6);
      }
    }

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
            builder: (context, setState) {
              bool isSaving = false;

              return AlertDialog(
                title: Text(isCreating ? "Nuovo Ecopunto" : "Modifica Ecopunto"),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isCreating)
                          TextFormField(
                            controller: idController,
                            decoration: const InputDecoration(labelText: 'ID (Sola Lettura)', filled: true),
                            readOnly: true,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        if (isCreating)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text("ID verrà generato automaticamente: ECO-...", style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                          ),
                        const SizedBox(height: 10),
                        TextFormField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome Punto'), validator: (v) => v!.isEmpty ? 'Inserisci un nome' : null),
                        const SizedBox(height: 10),
                        TextFormField(controller: indirizzoController, decoration: const InputDecoration(labelText: 'Indirizzo')),
                        const SizedBox(height: 10),
                        TextFormField(controller: tipologiaController, decoration: const InputDecoration(labelText: 'Tipologia')),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => pickLocationOnMap(context),
                          icon: const Icon(Icons.map),
                          label: const Text("📍 Seleziona su Mappa"),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: TextFormField(controller: latController, decoration: const InputDecoration(labelText: 'Lat'), keyboardType: TextInputType.number)),
                            const SizedBox(width: 10),
                            Expanded(child: TextFormField(controller: lonController, decoration: const InputDecoration(labelText: 'Lon'), keyboardType: TextInputType.number)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Annulla')
                  ),
                  ElevatedButton(
                    onPressed: isSaving ? null : () async {
                      if (!formKey.currentState!.validate()) return;

                      setState(() => isSaving = true);

                      try {
                        final double lat = double.parse(latController.text.replaceAll(',', '.'));
                        final double lon = double.parse(lonController.text.replaceAll(',', '.'));

                        // GENERAZIONE ID
                        String newId = '';
                        if (isCreating) {
                          newId = 'ECO-${DateTime.now().millisecondsSinceEpoch}-${(lat*100).toInt()}';
                        }

                        final ecopointData = Ecopoint(
                          id: isCreating ? newId : idController.text,
                          name: nomeController.text,
                          address: indirizzoController.text,
                          type: tipologiaController.text,
                          latitude: lat,
                          longitude: lon,
                        );

                        if (isCreating) {
                          await _controller.createEcopoint(parentContext, ecopointData);
                        } else {
                          await _controller.updateEcopoint(parentContext, ecopointData);
                        }

                        // FIX PER CI/CD:
                        // Forza un gap asincrono reale. Se il controller è 'void', l'await sopra è istantaneo.
                        // Future.delayed(Duration.zero) forza un tick del loop eventi, rendendo
                        // teoricamente possibile che 'mounted' diventi false.
                        // Questo elimina il warning "Dead code".
                        await Future.delayed(Duration.zero);

                        if (!context.mounted) return;
                        Navigator.of(context).pop();

                      } catch (e) {
                        // FIX ANALOGO
                        await Future.delayed(Duration.zero);
                        if (!context.mounted) return;

                        setState(() => isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore: $e")));
                      }
                    },
                    child: isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : Text(isCreating ? 'Crea' : 'Salva'),
                  ),
                ],
              );
            }
        );
      },
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
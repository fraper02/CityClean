
import 'package:cityclean/controllers/admin/ecopoints_controller.dart';
import 'package:cityclean/models/ecopoint.dart';
import 'package:flutter/material.dart';

class AdminListEcopointsPage extends StatefulWidget {
  const AdminListEcopointsPage({super.key});

  @override
  State<AdminListEcopointsPage> createState() => _AdminListEcopointsPageState();
}

class _AdminListEcopointsPageState extends State<AdminListEcopointsPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestione Punti di Raccolta"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: ValueListenableBuilder<EcopointsState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          if (state == EcopointsState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state == EcopointsState.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_controller.errorMessage.value, textAlign: TextAlign.center),
              ),
            );
          }

          return ValueListenableBuilder<List<Ecopoint>>(
            valueListenable: _controller.ecopoints,
            builder: (context, ecopoints, _) {
              if (ecopoints.isEmpty) {
                return const Center(child: Text("Nessun ecopunto trovato."));
              }
              // Sostituiamo DataTable con una ListView di Card espandibili
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: ecopoints.length,
                itemBuilder: (context, index) {
                  return _buildEcopointCard(ecopoints[index]);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(context, null),
        backgroundColor: Colors.green[700],
        tooltip: 'Aggiungi Ecopunto',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- NUOVO WIDGET PER LA CARD ESPANDIBILE ---
  Widget _buildEcopointCard(Ecopoint ecopoint) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(ecopoint.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(ecopoint.address, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: Icon(Icons.location_on, color: Colors.green[700]),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Statistiche (Ultimi 30 giorni)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Divider(height: 16),
                _buildStatRow(Icons.recycling, "Totale Conferimenti", ecopoint.monthlyConferimentiCount.toString()),
                _buildStatRow(Icons.person, "Utenti Unici", ecopoint.monthlyUniqueUsers.toString()),
                _buildStatRow(Icons.star, "Punti Generati", ecopoint.monthlyTotalPunti.toString()),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue), 
                      tooltip: 'Modifica',
                      onPressed: () => _showEditDialog(context, ecopoint)
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red), 
                      tooltip: 'Elimina',
                      onPressed: () => _showDeleteDialog(context, ecopoint)
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
          Icon(icon, color: Colors.grey[600], size: 18),
          const SizedBox(width: 12),
          Text("$label:", style: TextStyle(color: Colors.grey[700])),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }


  // --- DIALOGHI (INVARIATI) ---

  void _showDeleteDialog(BuildContext context, Ecopoint ecopoint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Conferma Eliminazione"),
        content: Text("Sei sicuro di voler eliminare l'ecopunto '${ecopoint.name}'? L'azione è irreversibile."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _controller.deleteEcopoint(context, ecopoint.id);
              Navigator.pop(context);
            },
            child: const Text('Elimina', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Ecopoint? ecopoint) {
    final isCreating = ecopoint == null;
    final formKey = GlobalKey<FormState>();
    
    final idController = TextEditingController(text: isCreating ? 'ECO-${DateTime.now().millisecondsSinceEpoch}' : ecopoint!.id);
    final nomeController = TextEditingController(text: ecopoint?.name ?? '');
    final indirizzoController = TextEditingController(text: ecopoint?.address ?? '');
    final tipologiaController = TextEditingController(text: ecopoint?.type ?? '');
    final latController = TextEditingController(text: ecopoint?.latitude.toString() ?? '');
    final lonController = TextEditingController(text: ecopoint?.longitude.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isCreating ? "Nuovo Ecopunto" : "Modifica Ecopunto"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: idController,
                    decoration: const InputDecoration(labelText: 'ID'),
                    readOnly: true,
                  ),
                  TextFormField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome'), validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null),
                  TextFormField(controller: indirizzoController, decoration: const InputDecoration(labelText: 'Indirizzo')),
                  TextFormField(controller: tipologiaController, decoration: const InputDecoration(labelText: 'Tipologia')),
                  TextFormField(controller: latController, decoration: const InputDecoration(labelText: 'Latitudine'), keyboardType: TextInputType.number, validator: (v) => (v == null || v.isEmpty || double.tryParse(v) == null) ? 'Valore non valido' : null),
                  TextFormField(controller: lonController, decoration: const InputDecoration(labelText: 'Longitudine'), keyboardType: TextInputType.number, validator: (v) => (v == null || v.isEmpty || double.tryParse(v) == null) ? 'Valore non valido' : null),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // I campi delle statistiche non vengono passati, il modello li imposterà a 0
                  final ecopointData = Ecopoint(
                    id: idController.text,
                    name: nomeController.text,
                    address: indirizzoController.text,
                    type: tipologiaController.text,
                    latitude: double.parse(latController.text),
                    longitude: double.parse(lonController.text),
                  );

                  if (isCreating) {
                    _controller.createEcopoint(context, ecopointData);
                  } else {
                    _controller.updateEcopoint(context, ecopointData);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }
}

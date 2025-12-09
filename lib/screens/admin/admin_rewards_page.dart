import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRewardsPage extends StatefulWidget {
  const AdminRewardsPage({super.key});

  @override
  State<AdminRewardsPage> createState() => _AdminRewardsPageState();
}

class _AdminRewardsPageState extends State<AdminRewardsPage> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _rewardsFuture;

  @override
  void initState() {
    super.initState();
    _rewardsFuture = _fetchRewards();
  }

  void _refreshData() {
    setState(() {
      _rewardsFuture = _fetchRewards();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchRewards() async {
    try {
      final response = await supabase
          .from('premio')
          .select()
          .order('nome', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Errore caricamento premi: $e");
      rethrow;
    }
  }

  // --- DIALOG AGGIUNGI / MODIFICA ---
  Future<void> _showRewardDialog({Map<String, dynamic>? premioEsistente}) async {
    final isEditing = premioEsistente != null;

    // Controllers
    final nomeController = TextEditingController(text: isEditing ? premioEsistente['nome'] : '');
    final descController = TextEditingController(text: isEditing ? premioEsistente['descrizione'] : '');
    final partnerController = TextEditingController(text: isEditing ? premioEsistente['idpartner'] : '');
    final costoController = TextEditingController(text: isEditing ? premioEsistente['costopunti'].toString() : '');
    final quantitaController = TextEditingController(text: isEditing ? premioEsistente['quantitadisponibile'].toString() : '');

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? "Modifica Premio" : "Nuovo Premio"),
        content: SizedBox(
          width: 400, // Larghezza fissa per desktop/tablet
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nomeController,
                    decoration: const InputDecoration(labelText: "Nome Premio", border: OutlineInputBorder()),
                    validator: (val) => val == null || val.isEmpty ? 'Obbligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: "Descrizione", border: OutlineInputBorder()),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: partnerController,
                    decoration: const InputDecoration(labelText: "ID Partner (Azienda)", border: OutlineInputBorder(), hintText: "Es. PARTNER-001"),
                    validator: (val) => val == null || val.isEmpty ? 'Obbligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: costoController,
                          decoration: const InputDecoration(labelText: "Costo (Punti)", border: OutlineInputBorder(), suffixText: "pts"),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (val) => val == null || val.isEmpty ? 'Obbligatorio' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: quantitaController,
                          decoration: const InputDecoration(labelText: "Quantità", border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (val) => val == null || val.isEmpty ? 'Obbligatorio' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annulla", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  // Prepara i dati
                  final data = {
                    'nome': nomeController.text.trim(),
                    'descrizione': descController.text.trim(),
                    'idpartner': partnerController.text.trim(),
                    'costopunti': int.parse(costoController.text),
                    'quantitadisponibile': int.parse(quantitaController.text),
                  };

                  if (isEditing) {
                    // UPDATE
                    await supabase.from('premio').update(data).eq('idpremio', premioEsistente['idpremio']);
                  } else {
                    // INSERT
                    // Genera ID se nuovo (es. REW-12345)
                    final newId = "REW-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(100)}";
                    data['idpremio'] = newId;

                    await supabase.from('premio').insert(data);
                  }

                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Salvataggio completato!"), backgroundColor: Colors.green),
                    );
                    _refreshData();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Errore: $e"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text(isEditing ? "Salva Modifiche" : "Crea Premio"),
          ),
        ],
      ),
    );
  }

  // --- ELIMINAZIONE ---
  Future<void> _deleteReward(String id, String nome) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Elimina Premio"),
        content: Text("Sei sicuro di voler eliminare '$nome'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annulla")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Elimina", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.from('premio').delete().eq('idpremio', id);
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Gestione Premi", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text("Configura il catalogo premi riscattabili dagli utenti.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showRewardDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text("Nuovo Premio"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),

            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _rewardsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Errore: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                    }

                    final rewards = snapshot.data ?? [];

                    if (rewards.isEmpty) {
                      return const Center(child: Text("Nessun premio presente nel catalogo."));
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 20,
                        headingRowColor: WidgetStateProperty.all(Colors.green[50]),
                        columns: const [
                          DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Partner', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Costo', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Disponibilità', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Azioni', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: rewards.map((r) {
                          final id = r['idpremio'];
                          final nome = r['nome'] ?? '-';
                          final partner = r['idpartner'] ?? '-';
                          final costo = r['costopunti'] ?? 0;
                          final qta = r['quantitadisponibile'] ?? 0;

                          // Colore quantità bassa
                          final qtaColor = qta < 5 ? Colors.red : Colors.black;

                          return DataRow(cells: [
                            DataCell(Text(nome, style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text(partner, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
                            DataCell(Chip(
                              label: Text("$costo pts"),
                              backgroundColor: Colors.amber[100],
                              labelStyle: TextStyle(color: Colors.amber[900], fontWeight: FontWeight.bold),
                            )),
                            DataCell(Text("$qta pz.", style: TextStyle(color: qtaColor, fontWeight: FontWeight.bold))),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showRewardDialog(premioEsistente: r),
                                  tooltip: "Modifica",
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.grey),
                                  onPressed: () => _deleteReward(id, nome),
                                  tooltip: "Elimina",
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
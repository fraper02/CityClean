import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminListEcopointsPage extends StatelessWidget {
  const AdminListEcopointsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista Punti Raccolta"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ecopunti Attivi",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Elenco di tutti i punti di raccolta configurati nel sistema.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Card(
                elevation: 2,
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  // Query: Seleziona tutti i punti raccolta
                  stream: supabase
                      .from('punto_raccolta')
                      .stream(primaryKey: ['idpuntoraccolta'])
                      .order('nome', ascending: true),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Errore: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final ecopoints = snapshot.data!;

                    if (ecopoints.isEmpty) {
                      return const Center(child: Text("Nessun punto raccolta trovato."));
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(Colors.green[50]),
                          columns: const [
                            DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Tipologia', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Coordinate', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Azioni', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: ecopoints.map((point) {
                            final nome = point['nome'] ?? 'N/A';
                            final tipo = point['tipologia'] ?? '-';
                            final lat = point['latitudine']?.toStringAsFixed(4) ?? '0';
                            final long = point['longitudine']?.toStringAsFixed(4) ?? '0';
                            final id = point['idpuntoraccolta'];

                            return DataRow(cells: [
                              DataCell(Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.green[700], size: 20),
                                  const SizedBox(width: 8),
                                  Text(nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              )),
                              DataCell(Chip(
                                label: Text(tipo, style: const TextStyle(fontSize: 12)),
                                backgroundColor: Colors.grey[200],
                              )),
                              DataCell(Text("$lat, $long", style: const TextStyle(fontFamily: 'monospace'))),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    tooltip: "Modifica",
                                    onPressed: () {
                                      // TODO: Implementare modifica
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: "Elimina",
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text("Eliminare Ecopunto?"),
                                          content: Text("Vuoi davvero eliminare $nome?"),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annulla")),
                                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Elimina", style: TextStyle(color: Colors.red))),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        try {
                                          await supabase.from('punto_raccolta').delete().eq('idpuntoraccolta', id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Eliminato con successo")));
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore: $e"), backgroundColor: Colors.red));
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
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
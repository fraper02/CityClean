import 'package:cityclean/models/aggiungi_punti.dart'; // Importa il nuovo model
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Per input numerici
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final supabase = Supabase.instance.client;

  // Usiamo un Future per gestire il caricamento iniziale e il refresh manuale
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  // Funzione per ricaricare i dati (utile dopo aver assegnato punti)
  void _refreshData() {
    setState(() {
      _usersFuture = _fetchUsers();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    try {
      final response = await supabase
          .from('utente')
          .select()
          .order('nome', ascending: true); // Ordinamento base

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("ERRORE QUERY: $e");
      // Rilanciamo l'errore per gestirlo nell'interfaccia se necessario
      // o ritorniamo lista vuota in caso di errore non bloccante
      rethrow;
    }
  }

  // --- LOGICA DIALOG AGGIUNTA PUNTI ---
  Future<void> _showAddPointsDialog(BuildContext context, String userId, String userName, int currentPoints) async {
    final pointsController = TextEditingController();

    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Assegna Punti a $userName"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Saldo attuale: $currentPoints punti"),
              const SizedBox(height: 16),
              TextField(
                controller: pointsController,
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))], // Solo numeri (anche negativi)
                decoration: const InputDecoration(
                  labelText: "Punti da aggiungere",
                  hintText: "Es. 50 o -20",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.stars),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Annulla", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                final pointsStr = pointsController.text;
                if (pointsStr.isEmpty) return;

                final int? points = int.tryParse(pointsStr);
                if (points == null || points == 0) return;

                // Chiudi il dialog prima dell'operazione asincrona per UI reattiva
                Navigator.pop(ctx);

                // Mostra un caricamento o feedback immediato
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Elaborazione in corso..."), duration: Duration(seconds: 1)),
                );

                // Chiamata al Model separato
                final success = await AggiungiPuntiModel.assegnaPunti(userId, points);

                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Successo! Nuovi punti assegnati a $userName."),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _refreshData(); // Ricarica la tabella per vedere i nuovi punti
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Errore durante l'assegnazione dei punti."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text("Conferma"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Gestione Utenti",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: "Ricarica Lista",
                onPressed: _refreshData,
              )
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: Card(
              elevation: 2,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: SelectableText(
                        "Errore: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final users = snapshot.data ?? [];

                  if (users.isEmpty) {
                    return const Center(child: Text("Nessun utente trovato."));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.green[50]),
                        columns: const [
                          DataColumn(label: Text('Nome e Cognome', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Referral', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Punti', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Ruolo', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Azioni', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: users.map((user) {
                          final id = user['idutente'] as String;
                          final nome = user['nome'] ?? 'N/A';
                          final cognome = user['cognome'] ?? '';
                          final email = user['email'] ?? '';
                          final referral = user['codicereferral'] ?? '-';
                          final punti = user['saldopunti'] ?? 0;
                          final isAdmin = user['isadmin'] == true;
                          final foto = user['fotoprofilo'];

                          return DataRow(cells: [
                            // 1. Nome e Avatar
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: foto != null ? NetworkImage(foto) : null,
                                  backgroundColor: Colors.green[100],
                                  child: foto == null
                                      ? Text(nome.isNotEmpty ? nome[0].toUpperCase() : '?',
                                      style: TextStyle(color: Colors.green[800], fontSize: 12))
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("$nome $cognome", style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(email, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  ],
                                ),
                              ],
                            )),

                            // 2. Referral
                            DataCell(Text(referral, style: const TextStyle(fontFamily: 'monospace'))),

                            // 3. Punti (Evidenziati)
                            DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.green[200]!)
                                  ),
                                  child: Text("$punti", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800])),
                                )
                            ),

                            // 4. Ruolo
                            DataCell(
                                isAdmin
                                    ? const Chip(
                                  label: Text("ADMIN", style: TextStyle(color: Colors.white, fontSize: 10)),
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                )
                                    : const Text("Utente")
                            ),

                            // 5. AZIONI (Modifica + Aggiungi Punti)
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Pulsante Modifica (Placeholder)
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.grey),
                                  tooltip: "Modifica Utente",
                                  onPressed: () {
                                    // Futura implementazione modifica anagrafica
                                  },
                                ),
                                // NUOVO PULSANTE: Assegna Punti
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: Colors.green),
                                  tooltip: "Assegna Punti",
                                  onPressed: () => _showAddPointsDialog(context, id, nome, punti),
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
    );
  }
}
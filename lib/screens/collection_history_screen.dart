import 'package:cityclean/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Per formattare la data

class CollectionHistoryScreen extends StatefulWidget {
  const CollectionHistoryScreen({super.key});

  @override
  State<CollectionHistoryScreen> createState() => _CollectionHistoryScreenState();
}

class _CollectionHistoryScreenState extends State<CollectionHistoryScreen> {
  late final Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchCollectionHistory();
  }

  /// Recupera lo storico delle sessioni per l'utente corrente.
  Future<List<Map<String, dynamic>>> _fetchCollectionHistory() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      // Se non c'è utente, restituisce una lista vuota
      return [];
    }

    try {
      final response = await supabase
          .from('sessione_raccolta')
          .select('timestamp, puntiguadagnati, dettaglirifiuto')
          .eq('idutente', user.id)
          .order('timestamp', ascending: false); // Ordina per i più recenti
      
      return response;
    } catch (e) {
      // In caso di errore, lancia un'eccezione per mostrarla nella UI
      throw Exception("Impossibile caricare lo storico: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storico Raccolte'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Errore: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Nessuna sessione di raccolta trovata.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final sessions = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final points = session['puntiguadagnati'] ?? 0;
              final timestamp = DateTime.parse(session['timestamp']);
              final formattedDate = DateFormat.yMMMMd('it_IT').add_Hm().format(timestamp);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Icon(Icons.recycling, color: Colors.green[800]),
                  ),
                  title: Text(
                    "+ $points Punti",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800], fontSize: 18),
                  ),
                  subtitle: Text(
                    "Effettuata il: $formattedDate",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  // Aggiungi un trailing per eventuali azioni future o dettagli
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    // Al tap, puoi mostrare i dettagli del rifiuto in un dialog
                    final details = session['dettaglirifiuto']?.toString() ?? "Nessun dettaglio disponibile.";
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Dettagli Rifiuto"),
                        content: Text(details),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Chiudi"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

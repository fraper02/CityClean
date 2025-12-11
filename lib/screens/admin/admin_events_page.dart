import 'package:cityclean/controllers/admin/admin_events_controller.dart';
import 'package:cityclean/models/event.dart';
import 'package:cityclean/screens/admin/admin_edit_event_page.dart';
import 'package:cityclean/screens/admin/admin_participants_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color adminPrimaryColor = Color(0xFF2E7D32);

class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({super.key});

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  late final AdminEventsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdminEventsController();
    _controller.loadEvents();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToEditPage([Event? event]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminEditEventPage(event: event)),
    );
    if (result == true) {
      _controller.loadEvents();
    }
  }

  void _navigateToParticipantsPage(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminParticipantsPage(eventId: event.id, eventTitle: event.titolo)),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Conferma Eliminazione'),
        content: Text('''Sei sicuro di voler eliminare l'evento "${event.titolo}"? L'azione è irreversibile.'''),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _controller.deleteEvent(event.id);
              Navigator.pop(ctx);
            },
            child: const Text('Elimina', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Eventi'),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: adminPrimaryColor), onPressed: () => _navigateToEditPage(), tooltip: 'Crea Evento'),
          IconButton(icon: const Icon(Icons.refresh, color: adminPrimaryColor), onPressed: _controller.loadEvents, tooltip: 'Aggiorna Eventi'),
        ],
      ),
      body: ValueListenableBuilder<AdminEventsState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          if (state == AdminEventsState.loading) {
            return const Center(child: CircularProgressIndicator(color: adminPrimaryColor));
          }
          if (state == AdminEventsState.error) {
            return Center(child: Text('Errore: ${_controller.errorMessage.value}'));
          }
          return ValueListenableBuilder<List<Event>>(
            valueListenable: _controller.events,
            builder: (context, events, _) {
              if (events.isEmpty) {
                return const Center(child: Text('Nessun evento trovato.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) => _buildEventCard(events[index]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.immagine != null && event.immagine!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(event.immagine!, height: 150, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, o, s) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.titolo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(event.descrizione, style: TextStyle(color: Colors.grey[700])),
                const Divider(height: 24),
                _buildInfoRow(Icons.location_on, 'Località', event.localita),
                if (event.dataOraInizio != null)
                  _buildInfoRow(Icons.date_range, 'Inizio', DateFormat('dd/MM/yyyy HH:mm').format(event.dataOraInizio!)),
                if (event.dataOraFine != null)
                  _buildInfoRow(Icons.date_range, 'Fine', DateFormat('dd/MM/yyyy HH:mm').format(event.dataOraFine!)),
                _buildInfoRow(Icons.people, 'Partecipanti', event.participantCount.toString()),
              ],
            ),
          ),
          // CORREZIONE DEFINITIVA: Sostituzione di Row con Wrap
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Wrap(
              alignment: WrapAlignment.end, // Allinea i pulsanti a destra
              spacing: 4.0, // Spazio orizzontale tra i pulsanti
              runSpacing: 0, // Spazio verticale se vanno a capo
              children: [
                TextButton(onPressed: () => _navigateToParticipantsPage(event), child: const Text('Modifica Partecipanti')),
                TextButton(onPressed: () => _navigateToEditPage(event), child: const Text('Modifica Evento')),
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _showDeleteConfirmation(context, event), tooltip: 'Elimina Evento'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: TextStyle(color: Colors.grey[900]))),
      ]),
    );
  }
}

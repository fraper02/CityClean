import 'package:cityclean/controllers/admin/admin_participants_controller.dart';
import 'package:cityclean/services/admin/admin_users_service.dart';
import 'package:flutter/material.dart';

const Color adminPrimaryColor = Color(0xFF2E7D32);

class AdminParticipantsPage extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const AdminParticipantsPage({super.key, required this.eventId, required this.eventTitle});

  @override
  State<AdminParticipantsPage> createState() => _AdminParticipantsPageState();
}

class _AdminParticipantsPageState extends State<AdminParticipantsPage> {
  late final AdminParticipantsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdminParticipantsController(eventId: widget.eventId);
    _controller.loadParticipants();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddParticipantDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _AddParticipantDialog(controller: _controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Partecipanti: ${widget.eventTitle}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddParticipantDialog,
        label: const Text('Aggiungi'),
        icon: const Icon(Icons.add),
        backgroundColor: adminPrimaryColor,
      ),
      body: ValueListenableBuilder<ParticipantsState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          if (state == ParticipantsState.loading) {
            return const Center(child: CircularProgressIndicator(color: adminPrimaryColor));
          }
          if (state == ParticipantsState.error) {
            return Center(child: Text('Errore: ${_controller.errorMessage.value}'));
          }
          return ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: _controller.participants,
            builder: (context, participants, _) {
              if (participants.isEmpty) {
                return const Center(child: Text('Nessun partecipante iscritto a questo evento.'));
              }
              return ListView.builder(
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final participant = participants[index];
                  final user = participant['utente'] ?? {};

                  return ListTile(
                    leading: CircleAvatar(child: Text(user['nome']?[0] ?? '?')),
                    title: Text('${user['nome'] ?? 'N/D'} ${user['cognome'] ?? ''}'),
                    subtitle: Text(user['email'] ?? 'Email non disponibile'),
                    trailing: IconButton(
                      icon: const Icon(Icons.person_remove_outlined, color: Colors.red),
                      onPressed: () => _controller.removeParticipant(participant['idutente']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Dialog per la ricerca e l'aggiunta di un utente
class _AddParticipantDialog extends StatefulWidget {
  final AdminParticipantsController controller;

  const _AddParticipantDialog({required this.controller});

  @override
  State<_AddParticipantDialog> createState() => _AddParticipantDialogState();
}

class _AddParticipantDialogState extends State<_AddParticipantDialog> {
  final AdminUsersService _usersService = AdminUsersService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  void _search(String query) async {
    if (query.length < 3) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      // Sfruttiamo il servizio esistente che filtra gli utenti
      final allUsers = await _usersService.getUsersWithStats();
      final results = allUsers.where((user) => 
        user.nome.toLowerCase().contains(query.toLowerCase()) || 
        user.cognome!.toLowerCase().contains(query.toLowerCase()) || 
        user.email.toLowerCase().contains(query.toLowerCase())
      ).map((u) => u.toJson()).toList(); // Converti a mappa per coerenza

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Gestisci errore
    }
  }

  void _add(String userId) async {
     try {
      await widget.controller.addParticipant(userId);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aggiungi Partecipante'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: _search,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Cerca per nome, cognome o email...', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        return ListTile(
                          title: Text('${user['nome']} ${user['cognome'] ?? ''}'),
                          subtitle: Text(user['email']),
                          onTap: () => _add(user['id']),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla'))],
    );
  }
}

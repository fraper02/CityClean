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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Partecipanti: ${widget.eventTitle}'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddParticipantDialog,
        label: const Text('Aggiungi'),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: adminPrimaryColor,
        foregroundColor: Colors.white,
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
                padding: const EdgeInsets.all(16),
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final participant = participants[index];
                  final user = participant['utente'] ?? {};

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: adminPrimaryColor.withOpacity(0.1),
                        child: Text(user['nome']?[0] ?? '?', style: const TextStyle(color: adminPrimaryColor, fontWeight: FontWeight.bold)),
                      ),
                      title: Text('${user['nome'] ?? 'N/D'} ${user['cognome'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(user['email'] ?? 'Email non disponibile'),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_remove_outlined, color: Colors.redAccent),
                        tooltip: 'Rimuovi Partecipante',
                        onPressed: () => _controller.removeParticipant(participant['idutente']),
                      ),
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
      if (mounted) {
        setState(() => _searchResults = []);
      }
      return;
    }
    if (mounted) {
      setState(() => _isLoading = true);
    }
    try {
      final allUsers = await _usersService.getUsersWithStats();
      final results = allUsers.where((user) => 
        user.nome.toLowerCase().contains(query.toLowerCase()) || 
        (user.cognome?.toLowerCase().contains(query.toLowerCase()) ?? false) || 
        user.email.toLowerCase().contains(query.toLowerCase())
      ).map((u) => u.toJson()).toList();

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _add(String userId) async {
     try {
      await widget.controller.addParticipant(userId);
      if (mounted) {
        Navigator.pop(context);
      }
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
              decoration: InputDecoration(
                hintText: 'Cerca per nome, cognome o email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: adminPrimaryColor)),
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: adminPrimaryColor))
                : Expanded(
                    child: _searchResults.isEmpty
                        ? const Center(child: Text('Nessun risultato.'))
                        : ListView.builder(
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

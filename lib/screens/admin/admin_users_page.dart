import 'package:cityclean/controllers/admin/admin_users_controller.dart';
import 'package:cityclean/models/user_activity.dart';
import 'package:cityclean/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

//##############################################################################
// 1. PAGINA PRINCIPALE CON LA LISTA DEGLI UTENTI
//##############################################################################

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  late final AdminUsersController _controller;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AdminUsersController();
    _controller.loadUsers();
    _searchController.addListener(() {
      _controller.filterUsers(_searchController.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monitoraggio Utenti"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Ricarica Utenti",
            onPressed: _controller.loadUsers,
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cerca per nome, cognome o email...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<AdminUsersState>(
              valueListenable: _controller.state,
              builder: (context, state, _) {
                if (state == AdminUsersState.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state == AdminUsersState.error) {
                  return Center(child: Text(_controller.errorMessage.value));
                }
                return ValueListenableBuilder<List<UserProfile>>(
                  valueListenable: _controller.users,
                  builder: (context, users, _) {
                    if (users.isEmpty) {
                      return const Center(child: Text("Nessun utente trovato."));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return _buildUserCard(users[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserProfile user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: user.fotoProfilo != null ? NetworkImage(user.fotoProfilo!) : null,
                  child: user.fotoProfilo == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${user.nome} ${user.cognome ?? ''}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(user.email, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                if (user.isAdmin) const Tooltip(message: 'Amministratore', child: Icon(Icons.shield, color: Colors.blue)),
              ],
            ),
            const Divider(height: 24),
            const Text("Attività Riepilogativa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            _buildStatRow(Icons.recycling, "Conferimenti totali", user.conferimentiCount.toString()),
            _buildStatRow(Icons.event, "Eventi partecipati", user.eventsCount.toString()),
            _buildStatRow(Icons.star, "Saldo Punti", user.saldoPunti.toString()),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.history, size: 20),
                  label: const Text('Vedi Storico'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _UserActivityPage(
                          controller: _controller, // Passa il controller
                          userId: user.id,
                          userName: user.nome,
                        ),
                      ),
                    ).then((_) => _controller.loadUsers()); 
                  },
                ),
                Tooltip(
                  message: 'Assegna Punti',
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle, size: 20),
                    label: const Text('Punti'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _showAddPointsDialog(context, user),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showAddPointsDialog(BuildContext context, UserProfile user) {
    final pointsController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Assegna Punti a ${user.nome}"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Saldo attuale: ${user.saldoPunti} punti"),
              const SizedBox(height: 16),
              TextFormField(
                controller: pointsController,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*'))],
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                decoration: const InputDecoration(labelText: "Punti", hintText: "Es. 50 oppure -20", border: OutlineInputBorder()),
                autofocus: true,
                validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null || int.parse(v) == 0) ? 'Valore non valido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Motivazione", hintText: "Es. Bonus speciale", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Motivazione obbligatoria' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annulla")),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                _controller.addPoints(context, user.id, int.parse(pointsController.text), descriptionController.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Conferma"),
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
}

//##############################################################################
// 2. PAGINA DELLO STORICO ATTIVITÀ UTENTE
//##############################################################################

class _UserActivityPage extends StatefulWidget {
  final AdminUsersController controller;
  final String userId;
  final String userName;

  const _UserActivityPage({
    required this.controller,
    required this.userId,
    required this.userName,
  });

  @override
  State<_UserActivityPage> createState() => _UserActivityPageState();
}

class _UserActivityPageState extends State<_UserActivityPage> {
  late Future<List<UserActivity>> _activityFuture;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  void _loadActivities() {
    _activityFuture = widget.controller.getUserActivity(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Storico di ${widget.userName}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Ricarica Storico",
            onPressed: () => setState(() => _loadActivities()),
          )
        ],
      ),
      body: FutureBuilder<List<UserActivity>>(
        future: _activityFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text("Errore: ${snapshot.error}")));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nessuna attività registrata per questo utente."));
          }

          final activities = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return _buildActivityTile(activities[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildActivityTile(UserActivity activity) {
    final icon = _getIconForActivity(activity.type);
    final color = _getColorForActivity(activity.type);
    final pointsText = activity.points != null ? (activity.points! > 0 ? '+${activity.points}' : activity.points.toString()) : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white, size: 20)),
        title: Text(activity.description, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(activity.date)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (pointsText != null) Text(pointsText, style: TextStyle(fontWeight: FontWeight.bold, color: activity.points! > 0 ? Colors.green : Colors.red, fontSize: 14)),
            if (activity.badgeName != null) Text(activity.badgeName!, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  IconData _getIconForActivity(ActivityType type) {
    switch (type) {
      case ActivityType.conferimento: return Icons.recycling;
      case ActivityType.missione: return Icons.flag;
      case ActivityType.obiettivo: return Icons.star;
      case ActivityType.badge: return Icons.shield;
      case ActivityType.premio: return Icons.card_giftcard;
      case ActivityType.admin_adjustment: return Icons.admin_panel_settings;
    }
  }

  Color _getColorForActivity(ActivityType type) {
    switch (type) {
      case ActivityType.conferimento: return Colors.green;
      case ActivityType.missione: return Colors.blue;
      case ActivityType.obiettivo: return Colors.orange;
      case ActivityType.badge: return Colors.purple;
      case ActivityType.premio: return Colors.red;
      case ActivityType.admin_adjustment: return Colors.grey;
    }
  }
}

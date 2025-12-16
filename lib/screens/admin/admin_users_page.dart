import 'package:cityclean/controllers/admin/admin_users_controller.dart';
import 'package:cityclean/models/user_activity.dart';
import 'package:cityclean/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

const Color adminPrimaryColor = Color(0xFF2E7D32);
const Color adminAccentColor = Color(0xFF66BB6A);

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  AdminUsersPageState createState() => AdminUsersPageState();
}

class AdminUsersPageState extends State<AdminUsersPage> {
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

  void refreshUsers() {
    _controller.loadUsers();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Cerca per nome, cognome o email...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: adminPrimaryColor)),
            ),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<AdminUsersState>(
            valueListenable: _controller.state,
            builder: (context, state, _) {
              if (state == AdminUsersState.loading) {
                return const Center(child: CircularProgressIndicator(color: adminPrimaryColor));
              }
              if (state == AdminUsersState.error) {
                return Center(child: Text(_controller.errorMessage.value, style: const TextStyle(color: Colors.red)));
              }
              return ValueListenableBuilder<List<UserProfile>>(
                valueListenable: _controller.users,
                builder: (context, users, _) {
                  if (users.isEmpty) {
                    return const Center(child: Text("Nessun utente trovato."));
                  }

                  // Ordina la lista: prima gli admin (in ordine alfabetico), poi gli altri (in ordine alfabetico)
                  final sortedUsers = List<UserProfile>.from(users);
                  sortedUsers.sort((a, b) {
                    if (a.isAdmin && !b.isAdmin) return -1;
                    if (!a.isAdmin && b.isAdmin) return 1;
                    // Se entrambi sono admin o entrambi non lo sono, ordina alfabeticamente per nome
                    return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
                  });

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sortedUsers.length,
                    itemBuilder: (context, index) {
                      return _buildUserCard(sortedUsers[index]);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
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
                  child: user.fotoProfilo == null ? const Icon(Icons.person, size: 30) : null,
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
                if (user.isAdmin) const Tooltip(message: 'Amministratore', child: Icon(Icons.shield, color: Colors.blueAccent)),
              ],
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildStatChip(Icons.recycling, user.conferimentiCount.toString(), "Conferimenti"),
                _buildStatChip(Icons.event, user.eventsCount.toString(), "Eventi"),
                _buildStatChip(Icons.star, user.saldoPunti.toString(), "Punti"),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.history, size: 20),
                  label: const Text('Storico'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _UserActivityPage(controller: _controller, userId: user.id, userName: user.nome),
                      ),
                    ).then((_) => _controller.loadUsers()); 
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle, size: 20),
                  label: const Text('Assegna Punti'),
                  style: ElevatedButton.styleFrom(backgroundColor: adminPrimaryColor, foregroundColor: Colors.white),
                  onPressed: () => _showAddPointsDialog(context, user),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Chip(
      avatar: Icon(icon, size: 18, color: adminPrimaryColor),
      label: Text('$value $label'),
      backgroundColor: adminAccentColor.withOpacity(0.1),
      side: BorderSide(color: adminAccentColor.withOpacity(0.3)),
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
        content: SingleChildScrollView(
          child: Form(
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
        ),
        actions: [
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8.0,
            children: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annulla")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: adminPrimaryColor, foregroundColor: Colors.white),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    _controller.addPoints(context, user.id, int.parse(pointsController.text), descriptionController.text);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text("Conferma"),
              ),
            ],
          )
        ],
      ),
    );
  }
}

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
      appBar: AppBar(title: Text("Storico di ${widget.userName}"), actions: [IconButton(icon: const Icon(Icons.refresh, color: adminPrimaryColor), tooltip: "Ricarica Storico", onPressed: () => setState(() => _loadActivities()))]),
      body: FutureBuilder<List<UserActivity>>(
        future: _activityFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: adminPrimaryColor));
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
            itemBuilder: (context, index) => _buildActivityTile(activities[index]),
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
      case ActivityType.adminAdjustment: return Icons.admin_panel_settings;
    }
  }

  Color _getColorForActivity(ActivityType type) {
    switch (type) {
      case ActivityType.conferimento: return adminAccentColor;
      case ActivityType.missione: return Colors.blue;
      case ActivityType.obiettivo: return Colors.orange;
      case ActivityType.badge: return Colors.purple;
      case ActivityType.premio: return Colors.red;
      case ActivityType.adminAdjustment: return Colors.grey;
    }
  }
}

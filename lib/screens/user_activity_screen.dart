import 'package:cityclean/controllers/user_activity_controller.dart';
import 'package:cityclean/models/user_activity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserActivityScreen extends StatefulWidget {
  const UserActivityScreen({super.key});

  @override
  State<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends State<UserActivityScreen> {
  late final UserActivityController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UserActivityController();
    _controller.loadActivities();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("La Mia Cronologia Attività")),
      body: ValueListenableBuilder<UserActivityState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          if (state == UserActivityState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state == UserActivityState.error) {
            return Center(child: Text(_controller.errorMessage.value));
          }
          return ValueListenableBuilder<List<UserActivity>>(
            valueListenable: _controller.activities,
            builder: (context, activities, _) {
              if (activities.isEmpty) {
                return const Center(child: Text("Nessuna attività registrata."));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  return _buildActivityTile(activities[index]);
                },
              );
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
    }
  }

  Color _getColorForActivity(ActivityType type) {
    switch (type) {
      case ActivityType.conferimento: return Colors.green;
      case ActivityType.missione: return Colors.blue;
      case ActivityType.obiettivo: return Colors.orange;
      case ActivityType.badge: return Colors.purple;
      case ActivityType.premio: return Colors.red;
    }
  }
}

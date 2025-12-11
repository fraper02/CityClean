import 'package:cityclean/models/user_profile.dart';
import 'package:cityclean/services/admin/admin_users_service.dart';
import 'package:flutter/material.dart';

enum AdminUsersState { initial, loading, success, error }

class AdminUsersController {
  final AdminUsersService _service;

  final ValueNotifier<AdminUsersState> state = ValueNotifier(AdminUsersState.initial);
  final ValueNotifier<List<UserProfile>> users = ValueNotifier([]);
  final ValueNotifier<String> errorMessage = ValueNotifier('');

  AdminUsersController({AdminUsersService? service}) : _service = service ?? AdminUsersService();

  Future<void> loadUsers() async {
    state.value = AdminUsersState.loading;
    try {
      users.value = await _service.getUsersWithStats();
      state.value = AdminUsersState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = AdminUsersState.error;
    }
  }

  Future<void> addPoints(BuildContext context, String userId, int points) async {
    try {
      await _service.addPointsToUser(userId, points);
      await loadUsers(); // Ricarica i dati per mostrare il saldo aggiornato
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$points punti aggiunti con successo!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void dispose() {
    state.dispose();
    users.dispose();
    errorMessage.dispose();
  }
}

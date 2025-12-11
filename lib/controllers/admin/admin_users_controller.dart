import 'package:cityclean/models/user_activity.dart';
import 'package:cityclean/models/user_profile.dart';
import 'package:cityclean/services/admin/admin_users_service.dart';
import 'package:flutter/material.dart';

enum AdminUsersState { initial, loading, success, error }

class AdminUsersController {
  final _service = AdminUsersService();

  final state = ValueNotifier<AdminUsersState>(AdminUsersState.initial);
  final users = ValueNotifier<List<UserProfile>>([]);
  final errorMessage = ValueNotifier<String>('');

  // Lista per mantenere tutti gli utenti originali
  List<UserProfile> _allUsers = [];

  Future<void> loadUsers() async {
    state.value = AdminUsersState.loading;
    try {
      // Salva la lista completa e aggiorna quella filtrata
      _allUsers = await _service.getUsersWithStats();
      users.value = _allUsers;
      state.value = AdminUsersState.success; // Corretto
    } catch (e) {
      errorMessage.value = "Errore nel caricamento: ${e.toString()}";
      state.value = AdminUsersState.error;
    }
  }

  // Nuovo metodo per filtrare gli utenti
  void filterUsers(String query) {
    if (query.isEmpty) {
      users.value = _allUsers;
    } else {
      final lowerCaseQuery = query.toLowerCase();
      users.value = _allUsers.where((user) {
        final nameMatch = user.nome.toLowerCase().contains(lowerCaseQuery);
        final surnameMatch = user.cognome?.toLowerCase().contains(lowerCaseQuery) ?? false;
        final emailMatch = user.email.toLowerCase().contains(lowerCaseQuery);
        return nameMatch || surnameMatch || emailMatch;
      }).toList();
    }
  }

  Future<void> addPoints(BuildContext context, String userId, int points, String description) async {
    try {
      await _service.addPointsToUser(userId, points, description);
      await loadUsers(); // Ricarica i dati per mostrare il saldo aggiornato
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$points punti aggiunti con successo!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Aggiunta la funzione per caricare lo storico
  Future<List<UserActivity>> getUserActivity(String userId) {
    return _service.getUserActivity(userId);
  }

  void dispose() {
    state.dispose();
    users.dispose();
    errorMessage.dispose();
  }
}

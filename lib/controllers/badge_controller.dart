import 'package:flutter/material.dart';
import '../models/badge.dart' as app_badge;
import '../services/badge_service.dart';

enum BadgeScreenState { initial, loading, success, error }

class BadgeController {
  final BadgeService _service;

  final ValueNotifier<BadgeScreenState> state = ValueNotifier(BadgeScreenState.initial);
  final ValueNotifier<List<app_badge.Badge>> badges = ValueNotifier([]);
  final ValueNotifier<String> errorMessage = ValueNotifier('');

  BadgeController({BadgeService? service}) : _service = service ?? BadgeService();

  Future<void> loadBadges() async {
    state.value = BadgeScreenState.loading;
    try {
      final badgeList = await _service.getBadgesWithUnlockStatus();
      badges.value = badgeList;
      state.value = BadgeScreenState.success;
    } catch (e) {
      final errorMsg = e.toString().replaceFirst("Exception: ", "");
      errorMessage.value = errorMsg;
      state.value = BadgeScreenState.error;
    }
  }

  // Metodo che mostra il dialogo. La logica della UI è qui, non più nello Screen.
  void showBadgeDetails(BuildContext context, app_badge.Badge badge) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Row(
            children: [
              badge.isUnlocked
                  ? Icon(Icons.check_circle_outline, color: Colors.green[700])
                  : const Icon(Icons.lock_outline, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(child: Text(badge.nome, style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          content: Text(badge.descrizione.isNotEmpty
              ? badge.descrizione
              : "Nessuna descrizione disponibile per questo badge."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Chiudi'),
            ),
          ],
        );
      },
    );
  }

  void dispose() {
    state.dispose();
    badges.dispose();
    errorMessage.dispose();
  }
}

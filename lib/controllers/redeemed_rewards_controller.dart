// lib/controllers/redeemed_rewards_controller.dart

import 'package:flutter/foundation.dart'; // Per ValueNotifier
import '../models/redeemed_reward.dart';
import '../services/redeemed_rewards_service.dart';

// Enum per rappresentare i possibili stati della nostra UI
enum ScreenState { initial, loading, success, error }

/// Controller per la schermata dei premi riscattati.
/// Gestisce lo stato e la logica di business, fungendo da ponte
/// tra la UI e i service.
class RedeemedRewardsController {
  final RedeemedRewardsService _service;

  // Notifier per lo stato generale della schermata (loading, success, error)
  final ValueNotifier<ScreenState> state = ValueNotifier(ScreenState.initial);

  // Notifier per la lista dei premi (i dati veri e propri)
  final ValueNotifier<List<RedeemedReward>> rewards = ValueNotifier([]);

  // Notifier per eventuali messaggi di errore
  final ValueNotifier<String> errorMessage = ValueNotifier('');

  // Il costruttore può accettare un service per facilitare il testing
  RedeemedRewardsController({RedeemedRewardsService? service})
      : _service = service ?? RedeemedRewardsService();

  /// Metodo pubblico che la UI chiamerà per caricare i dati.
  Future<void> fetchRedeemedRewards() async {
    // 1. Imposta lo stato su "loading" e notifica gli ascoltatori
    state.value = ScreenState.loading;

    try {
      // 2. Chiama il service per ottenere i dati
      final fetchedRewards = await _service.getRedeemedRewards();

      // 3. Aggiorna il notifier dei dati e imposta lo stato su "success"
      rewards.value = fetchedRewards;
      state.value = ScreenState.success;
    } catch (e) {
      // 4. In caso di errore, aggiorna il messaggio e imposta lo stato su "error"
      errorMessage.value = e.toString().replaceFirst("Exception: ", "");
      state.value = ScreenState.error;
    }
  }

  /// Metodo per liberare le risorse quando il controller non è più usato.
  void dispose() {
    state.dispose();
    rewards.dispose();
    errorMessage.dispose();
  }
}

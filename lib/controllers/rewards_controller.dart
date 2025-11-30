// lib/controllers/rewards_controller.dart

import 'package:cityclean/services/reedeem_service.dart';
import 'package:flutter/foundation.dart';
import '../models/prizes.dart';

// Riutilizziamo lo stesso enum per lo stato della schermata
enum ScreenState { initial, loading, success, error }

/// Controller per la schermata di riscatto premi.
/// Fa da ponte tra la UI (RewardsScreen) e la logica di business (RedeemService).
class RewardsController {
  final RedeemService _service;

  // --- State Notifiers ---
  final ValueNotifier<ScreenState> state = ValueNotifier(ScreenState.initial);
  final ValueNotifier<int> userPoints = ValueNotifier(0);
  final ValueNotifier<List<Prize>> availablePrizes = ValueNotifier([]);
  final ValueNotifier<String> errorMessage = ValueNotifier('');

  RewardsController({RedeemService? service})
      : _service = service ?? RedeemService();

  /// Carica i dati iniziali per la schermata (punti e premi).
  Future<void> loadScreenData() async {
    state.value = ScreenState.loading;
    try {
      final data = await _service.loadRewardsScreenData();
      userPoints.value = data['userPoints'];
      availablePrizes.value = data['availablePrizes'];
      state.value = ScreenState.success;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst("Exception: ", "");
      state.value = ScreenState.error;
    }
  }

  /// Gestisce la logica di riscatto di un premio.
  Future<void> redeemPrize(Prize prize) async {
    // Non cambiamo lo stato principale in "loading" per non far sparire la UI,
    // ma potremmo aggiungere un notifier specifico se volessimo mostrare un caricamento sul pulsante.
    try {
      await _service.redeemPrize(prize);
      // Dopo un riscatto andato a buon fine, ricarichiamo tutti i dati
      // per aggiornare sia i punti utente che la quantità del premio.
      await loadScreenData();
    } catch (e) {
      // Se il riscatto fallisce, l'errore verrà mostrato tramite uno SnackBar nella UI.
      // Rigettiamo l'eccezione in modo che la UI possa catturarla.
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  /// Libera le risorse.
  void dispose() {
    state.dispose();
    userPoints.dispose();
    availablePrizes.dispose();
    errorMessage.dispose();
  }
}

import 'package:cityclean/models/segnalazione.dart';
import 'package:cityclean/services/admin/segnalazioni_service.dart';
import 'package:flutter/foundation.dart';

enum SegnalazioniState { initial, loading, success, error }

class SegnalazioniController {
  final SegnalazioniService _service;

  final state = ValueNotifier(SegnalazioniState.initial);
  final segnalazioni = ValueNotifier<List<Segnalazione>>([]);
  final errorMessage = ValueNotifier('');

  SegnalazioniController({SegnalazioniService? service}) : _service = service ?? SegnalazioniService();

  Future<void> loadSegnalazioni() async {
    state.value = SegnalazioniState.loading;
    try {
      segnalazioni.value = await _service.getSegnalazioni();
      state.value = SegnalazioniState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = SegnalazioniState.error;
    }
  }

  // Nuovo metodo per aggiornare lo stato e ricaricare la lista
  Future<void> updateStatus(String segnalazioneId, bool approvata) async {
    try {
      await _service.updateSegnalazioneStatus(segnalazioneId, approvata);
      // Ricarica la lista per mostrare lo stato aggiornato
      await loadSegnalazioni();
    } catch (e) {
      // Gestisci l'errore mostrando un messaggio all'utente, se necessario
      print("Errore nell'aggiornare lo stato: $e");
      errorMessage.value = "Impossibile aggiornare lo stato della segnalazione.";
      // Potresti voler notificare la UI in qualche modo
    }
  }

  void dispose() {
    state.dispose();
    segnalazioni.dispose();
    errorMessage.dispose();
  }
}

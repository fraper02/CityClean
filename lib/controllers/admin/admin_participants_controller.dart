import 'package:cityclean/services/admin/admin_events_service.dart';
import 'package:flutter/foundation.dart';

enum ParticipantsState { initial, loading, success, error }

class AdminParticipantsController {
  final AdminEventsService _service;
  final String eventId;

  final state = ValueNotifier(ParticipantsState.initial);
  final participants = ValueNotifier<List<Map<String, dynamic>>>([]);
  final errorMessage = ValueNotifier('');

  AdminParticipantsController({required this.eventId, AdminEventsService? service}) 
      : _service = service ?? AdminEventsService();

  Future<void> loadParticipants() async {
    state.value = ParticipantsState.loading;
    try {
      participants.value = await _service.getParticipants(eventId);
      state.value = ParticipantsState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = ParticipantsState.error;
    }
  }

  Future<void> removeParticipant(String userId) async {
    try {
      await _service.removeParticipant(eventId, userId);
      await loadParticipants(); // Ricarica la lista
    } catch (e) {
      errorMessage.value = "Errore nella rimozione: ${e.toString()}";
      // Notifica la UI dell'errore
    }
  }
  
  Future<void> addParticipant(String userId) async {
    try {
      await _service.addParticipant(eventId, userId);
      await loadParticipants(); // Ricarica la lista
    } catch (e) {
      errorMessage.value = e.toString();
      // CORREZIONE: Uso 'rethrow' per preservare lo stack trace
      rethrow;
    }
  }

  void dispose() {
    state.dispose();
    participants.dispose();
    errorMessage.dispose();
  }
}

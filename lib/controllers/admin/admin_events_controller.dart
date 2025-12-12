import 'package:cityclean/models/event.dart';
import 'package:cityclean/services/admin/admin_events_service.dart';
import 'package:flutter/foundation.dart';

enum AdminEventsState { initial, loading, success, error }

class AdminEventsController {
  final AdminEventsService _service;

  final state = ValueNotifier(AdminEventsState.initial);
  final events = ValueNotifier<List<Event>>([]);
  final errorMessage = ValueNotifier('');

  AdminEventsController({AdminEventsService? service}) : _service = service ?? AdminEventsService();

  Future<void> loadEvents() async {
    state.value = AdminEventsState.loading;
    try {
      events.value = await _service.getEvents();
      state.value = AdminEventsState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = AdminEventsState.error;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _service.deleteEvent(eventId);
      await loadEvents(); // Ricarica la lista dopo l'eliminazione
    } catch (e) {
      errorMessage.value = e.toString();
      // Potresti voler notificare la UI in qualche modo
    }
  }

  void dispose() {
    state.dispose();
    events.dispose();
    errorMessage.dispose();
  }
}

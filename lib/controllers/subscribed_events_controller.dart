// lib/controllers/subscribed_events_controller.dart

import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../main.dart'; // Per accedere a supabase

enum ScreenState { initial, loading, success, error }

class SubscribedEventsController {
  final EventService _service;

  final ValueNotifier<ScreenState> state = ValueNotifier(ScreenState.initial);
  final ValueNotifier<List<Event>> subscribedEvents = ValueNotifier([]);
  final ValueNotifier<String> errorMessage = ValueNotifier('');

  SubscribedEventsController({EventService? service}) 
      : _service = service ?? EventService();

  Future<void> loadSubscribedEvents() async {
    state.value = ScreenState.loading;
    try {
      final events = await _service.getMyEvents();
      subscribedEvents.value = events;
      state.value = ScreenState.success;

    } catch (e) {
      errorMessage.value = e.toString().replaceFirst("Exception: ", "");
      state.value = ScreenState.error;
    }
  }

  // Metodo per annullare l'iscrizione
  Future<void> unsubscribeFromEvent(String eventId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception("Utente non autenticato.");
    }

    try {
      await _service.unsubscribeFromEvent(eventId, userId);
      // CORREZIONE: Ricarica i dati dal server invece di aggiornare solo la UI.
      // Questo garantisce che la UI rifletta sempre lo stato reale del database.
      await loadSubscribedEvents();
    } catch (e) {
      // Rigetta l'errore per mostrarlo nella UI
      throw Exception('Errore durante l\'annullamento dell\'iscrizione: ${e.toString()}');
    }
  }

  void dispose() {
    state.dispose();
    subscribedEvents.dispose();
    errorMessage.dispose();
  }
}

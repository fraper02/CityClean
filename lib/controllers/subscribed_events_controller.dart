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
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("Utente non autenticato.");
      }

      final events = await _service.getSubscribedEvents(userId);
      subscribedEvents.value = events;
      state.value = ScreenState.success;

    } catch (e) {
      errorMessage.value = e.toString().replaceFirst("Exception: ", "");
      state.value = ScreenState.error;
    }
  }

  // --- NUOVO METODO PER ANNULLARE L'ISCRIZIONE ---
  Future<void> unsubscribeFromEvent(String eventId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception("Utente non autenticato.");
    }

    try {
      // 1. Chiama il service per cancellare l'iscrizione dal DB
      await _service.unsubscribeFromEvent(eventId, userId);
      // 2. Rimuove l'evento dalla lista locale per un aggiornamento istantaneo della UI
      final currentEvents = List<Event>.from(subscribedEvents.value);
      currentEvents.removeWhere((event) => event.id == eventId);
      subscribedEvents.value = currentEvents;
    } catch (e) {
      // Rigetta l'errore in modo che la UI possa mostrarlo
      throw Exception('Errore durante l\'annullamento dell\'iscrizione.');
    }
  }

  void dispose() {
    state.dispose();
    subscribedEvents.dispose();
    errorMessage.dispose();
  }
}

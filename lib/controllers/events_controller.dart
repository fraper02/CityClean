// lib/controllers/events_controller.dart

import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../main.dart'; // Per accedere a supabase.auth.currentUser

enum ScreenState { initial, loading, success, error }

class EventsController {
  final EventService _service;

  final ValueNotifier<ScreenState> state = ValueNotifier(ScreenState.initial);
  final ValueNotifier<List<Event>> _allEvents = ValueNotifier([]);
  final ValueNotifier<List<Event>> filteredEvents = ValueNotifier([]);
  final ValueNotifier<String> errorMessage = ValueNotifier('');
  final ValueNotifier<Set<String>> subscribedEventIds = ValueNotifier({});

  EventsController({EventService? service}) : _service = service ?? EventService();

  Future<void> loadEvents() async {
    state.value = ScreenState.loading;
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("Utente non autenticato. Impossibile caricare i dati.");
      }

      final results = await Future.wait([
        _service.getEvents(),
        _service.getSubscribedEventIds(userId),
      ]);

      final fetchedEvents = results[0] as List<Event>;
      final fetchedSubscribedIds = results[1] as Set<String>;

      _allEvents.value = fetchedEvents;
      filteredEvents.value = fetchedEvents;
      subscribedEventIds.value = fetchedSubscribedIds;
      
      state.value = ScreenState.success;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst("Exception: ", "");
      state.value = ScreenState.error;
    }
  }

  Future<void> toggleSubscription(String eventId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception("Devi essere autenticato per iscriverti.");
    }

    final isSubscribed = subscribedEventIds.value.contains(eventId);
    final currentIds = Set<String>.from(subscribedEventIds.value);

    try {
      if (isSubscribed) {
        await _service.unsubscribeFromEvent(eventId, userId);
        currentIds.remove(eventId);
      } else {
        await _service.subscribeToEvent(eventId, userId);
        currentIds.add(eventId);
      }
      subscribedEventIds.value = currentIds;
    } catch (e) {
      debugPrint('Errore durante l\'aggiornamento dell\'iscrizione: $e');
      throw Exception('Si è verificato un errore. Riprova.');
    }
  }

  void filterEvents(String keyword) {
    if (keyword.isEmpty) {
      filteredEvents.value = _allEvents.value;
    } else {
      final lowerCaseKeyword = keyword.toLowerCase();
      filteredEvents.value = _allEvents.value.where((event) {
        return event.title.toLowerCase().contains(lowerCaseKeyword) ||
               event.location.toLowerCase().contains(lowerCaseKeyword);
      }).toList();
    }
  }

  void dispose() {
    state.dispose();
    _allEvents.dispose();
    filteredEvents.dispose();
    errorMessage.dispose();
    subscribedEventIds.dispose();
  }
}

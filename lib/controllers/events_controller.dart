import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../main.dart';

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

  Future<void> toggleSubscription(BuildContext context, String eventId, String eventTitle) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Devi essere autenticato per iscriverti."), backgroundColor: Colors.red),
      );
      return;
    }

    final isCurrentlySubscribed = subscribedEventIds.value.contains(eventId);

    try {
      if (isCurrentlySubscribed) {
        await _service.unsubscribeFromEvent(eventId, userId);
        final newIds = Set<String>.from(subscribedEventIds.value)..remove(eventId);
        subscribedEventIds.value = newIds;
      } else {
        await _service.subscribeToEvent(eventId, userId);
        final newIds = Set<String>.from(subscribedEventIds.value)..add(eventId);
        subscribedEventIds.value = newIds;
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!isCurrentlySubscribed
                ? "Ti sei iscritto a: $eventTitle"
                : "Hai annullato l'iscrizione a: $eventTitle"),
            backgroundColor: !isCurrentlySubscribed ? Colors.green : Colors.orange,
          ),
        );
      }

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
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

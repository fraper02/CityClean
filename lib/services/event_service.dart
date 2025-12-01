// lib/services/event_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../main.dart'; // Per accedere a supabase

class EventService {
  Future<List<Event>> getEvents() async {
    try {
      final response = await supabase.from('evento').select();
      final List<Event> events = (response as List)
          .map((data) => Event.fromJson(data as Map<String, dynamic>))
          .toList();
      events.sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
      return events;
    } on PostgrestException catch (e) {
      debugPrint('ERRORE SUPABASE [getEvents]: ${e.message}');
      throw Exception('Errore dal database: ${e.message}');
    } catch (e) {
      throw Exception('Errore durante il recupero degli eventi: $e');
    }
  }

  Future<Set<String>> getSubscribedEventIds(String userId) async {
    try {
      final response = await supabase
          .from('partecipazione')
          .select('idevento')
          .eq('idutente', userId);

      if (response.isEmpty) {
        return {};
      }
      
      final ids = (response as List)
          .map((item) => item['idevento'].toString())
          .toSet();
      return ids;
    } on PostgrestException catch (e) {
      debugPrint('ERRORE SUPABASE [getSubscribedEventIds]: ${e.message}');
      throw Exception('Errore dal database: ${e.message}');
    } catch (e) {
      throw Exception('Errore nel recupero delle iscrizioni: $e');
    }
  }

  // --- CORREZIONE DEFINITIVA ---
  Future<List<Event>> getSubscribedEvents(String userId) async {
    try {
      // Usa una JOIN per recuperare direttamente gli eventi corretti in una sola chiamata.
      // 1. Seleziona tutte le colonne (*) dalla tabella 'evento'.
      // 2. Esegue una JOIN con la tabella 'partecipazione' (!inner).
      // 3. Filtra i risultati dove 'idutente' nella tabella 'partecipazione' è quello corretto.
      final response = await supabase
          .from('evento')
          .select('*, partecipazione!inner(*)')
          .eq('partecipazione.idutente', userId);

      final List<Event> events = (response as List)
          .map((data) => Event.fromJson(data as Map<String, dynamic>))
          .toList();

      events.sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
      return events;

    } on PostgrestException catch (e) {
      debugPrint('ERRORE SUPABASE [getSubscribedEvents]: ${e.message}');
      throw Exception('Errore dal database: ${e.message}');
    } catch (e) {
      debugPrint('ERRORE GENERICO [getSubscribedEvents]: $e');
      throw Exception('Errore sconosciuto nel recupero degli eventi.');
    }
  }


  Future<void> subscribeToEvent(String eventId, String userId) async {
    try {
      await supabase.from('partecipazione').insert({
        'idutente': userId,
        'idevento': eventId,
      });
    } on PostgrestException catch (e) {
      debugPrint('ERRORE SUPABASE [subscribe]: ${e.message}');
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      debugPrint('ERRORE GENERICO [subscribe]: $e');
      throw Exception('Errore sconosciuto durante l\'iscrizione.');
    }
  }

  Future<void> unsubscribeFromEvent(String eventId, String userId) async {
    try {
      await supabase
          .from('partecipazione')
          .delete()
          .match({'idutente': userId, 'idevento': eventId});
    } on PostgrestException catch (e) {
      debugPrint('ERRORE SUPABASE [unsubscribe]: ${e.message}');
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      debugPrint('ERRORE GENERICO [unsubscribe]: $e');
      throw Exception('Errore sconosciuto durante l\'annullamento.');
    }
  }
}

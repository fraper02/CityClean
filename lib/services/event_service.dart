import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../main.dart';

class EventService {
  String? get _userId => supabase.auth.currentUser?.id;

  // Recupera tutti gli eventi e il numero di partecipanti per ciascuno
  Future<List<Event>> getEvents() async {
    try {
      final response = await supabase.from('evento').select('*, partecipazione(count)');

      final List<Event> events = (response as List)
          .map((data) => Event.fromJson(data as Map<String, dynamic>))
          .toList();

      events.sort((a, b) {
        if (a.dataOraInizio == null && b.dataOraInizio == null) return 0;
        if (a.dataOraInizio == null) return 1;
        if (b.dataOraInizio == null) return -1;
        return b.dataOraInizio!.compareTo(a.dataOraInizio!);
      });

      return events;
    } on PostgrestException catch (e) {
      debugPrint('ERRORE SUPABASE [getEvents]: ${e.message}');
      throw Exception('Errore dal database: ${e.message}');
    } catch (e) {
      debugPrint('ERRORE GENERICO [getEvents]: $e');
      throw Exception('Errore durante il recupero degli eventi: $e');
    }
  }

  // Recupera solo gli eventi a cui l'utente corrente è iscritto.
  Future<List<Event>> getMyEvents() async {
    if (_userId == null) {
      return [];
    }

    try {
      // 1. Ottieni gli ID degli eventi a cui l'utente è iscritto.
      final participationResponse = await supabase
          .from('partecipazione')
          .select('idevento')
          .eq('idutente', _userId!);

      final List<String> eventIds = (participationResponse as List)
          .map((e) => e['idevento'].toString())
          .toList();

      if (eventIds.isEmpty) {
        return [];
      }

      // 2. Recupera i dettagli completi solo per quegli eventi.
      // CORREZIONE QUI: Usiamo .filter invece di .in_ per massima compatibilità
      final response = await supabase
          .from('evento')
          .select('*, partecipazione(count)')
          .filter('idevento', 'in', eventIds); // <--- RIGA CORRETTA

      final List<Event> events = (response as List)
          .map((data) => Event.fromJson(data as Map<String, dynamic>))
          .toList();

      // Ordina gli eventi per data, dal più recente al meno recente.
      events.sort((a, b) {
        if (a.dataOraInizio == null && b.dataOraInizio == null) return 0;
        if (a.dataOraInizio == null) return 1;
        if (b.dataOraInizio == null) return -1;
        return b.dataOraInizio!.compareTo(a.dataOraInizio!);
      });

      return events;

    } on PostgrestException catch (e) {
      debugPrint('ERRORE SUPABASE [getMyEvents]: ${e.message}');
      throw Exception('Errore nel recupero delle iscrizioni: ${e.message}');
    } catch (e) {
      debugPrint('ERRORE GENERICO [getMyEvents]: $e');
      throw Exception('Errore sconosciuto durante il recupero degli eventi: $e');
    }
  }

  // Recupera solo gli ID degli eventi a cui l'utente è iscritto
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

  // Iscrive un utente a un evento
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
      throw Exception("Errore sconosciuto durante l'iscrizione.");
    }
  }

  // Annulla l'iscrizione di un utente da un evento
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
      throw Exception("Errore sconosciuto durante l'annullamento.");
    }
  }
}
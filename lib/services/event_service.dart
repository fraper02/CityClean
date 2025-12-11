import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../main.dart';

class EventService {
  // Recupera tutti gli eventi e il numero di partecipanti per ciascuno
  Future<List<Event>> getEvents() async {
    try {
      // La query ora include una sub-query per contare le partecipazioni
      final response = await supabase.from('evento').select('*, partecipazione(count)');
      
      final List<Event> events = (response as List)
          .map((data) => Event.fromJson(data as Map<String, dynamic>))
          .toList();
      
      // CORREZIONE: Ordina usando il campo corretto 'dataOraInizio'
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

  // Recupera i dettagli completi degli eventi a cui l'utente è iscritto
  Future<List<Event>> getSubscribedEvents(String userId) async {
    try {
      // La query fa una join con la tabella partecipazione e poi recupera i dettagli dell'evento
      final response = await supabase
          .from('evento')
          .select('*, partecipazione!inner(count)') // Conta anche qui i partecipanti totali
          .eq('partecipazione.idutente', userId);

      final List<Event> events = (response as List)
          .map((data) => Event.fromJson(data as Map<String, dynamic>))
          .toList();

      // CORREZIONE: Ordina usando il campo corretto 'dataOraInizio'
      events.sort((a, b) {
        if (a.dataOraInizio == null && b.dataOraInizio == null) return 0;
        if (a.dataOraInizio == null) return 1;
        if (b.dataOraInizio == null) return -1;
        return b.dataOraInizio!.compareTo(a.dataOraInizio!);
      });
      return events;

    } on PostgrestException catch (e) {
      debugPrint('ERRORE SUPABASE [getSubscribedEvents]: ${e.message}');
      throw Exception('Errore dal database: ${e.message}');
    } catch (e) {
      debugPrint('ERRORE GENERICO [getSubscribedEvents]: $e');
      throw Exception('Errore sconosciuto nel recupero degli eventi.');
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
      throw Exception('Errore sconosciuto durante l\'iscrizione.');
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
      throw Exception('Errore sconosciuto durante l\'annullamento.');
    }
  }
}

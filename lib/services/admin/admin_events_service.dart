import 'package:cityclean/models/event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminEventsService {
  final SupabaseClient _supabase;

  AdminEventsService({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  // Legge tutti gli eventi e conta i partecipanti per ognuno
  Future<List<Event>> getEvents() async {
    try {
      final response = await _supabase
          .from('evento')
          .select('*, partecipazione(count)') // Sub-query per contare i partecipanti
          .order('dataorainizio', ascending: false);

      final data = response as List;
      return data.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      print("Errore nel recupero degli eventi: $e");
      throw Exception("Impossibile caricare gli eventi.");
    }
  }

  // Crea un nuovo evento
  Future<void> createEvent(Map<String, dynamic> eventData) async {
    try {
      await _supabase.from('evento').insert(eventData);
    } catch (e) {
      print("Errore nella creazione dell'evento: $e");
      throw Exception("Impossibile creare l'evento.");
    }
  }

  // Aggiorna un evento esistente
  Future<void> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    try {
      await _supabase.from('evento').update(eventData).eq('idevento', eventId);
    } catch (e) {
      print("Errore nell'aggiornamento dell'evento: $e");
      throw Exception("Impossibile aggiornare l'evento.");
    }
  }

  // Elimina un evento
  Future<void> deleteEvent(String eventId) async {
    try {
      // Prima elimina le partecipazioni collegate per evitare errori di foreign key
      await _supabase.from('partecipazione').delete().eq('idevento', eventId);
      // Poi elimina l'evento
      await _supabase.from('evento').delete().eq('idevento', eventId);
    } catch (e) {
      print("Errore nell'eliminazione dell'evento: $e");
      throw Exception("Impossibile eliminare l'evento.");
    }
  }

  // --- Gestione Partecipanti ---

  Future<List<Map<String, dynamic>>> getParticipants(String eventId) async {
    try {
      final response = await _supabase
          .from('partecipazione')
          .select('idutente, utente(nome, cognome, email)')
          .eq('idevento', eventId);
      // CORREZIONE: Rimosso il cast non necessario
      return response;
    } catch (e) {
      print("Errore nel recupero dei partecipanti: $e");
      throw Exception("Impossibile caricare i partecipanti.");
    }
  }

  Future<void> removeParticipant(String eventId, String userId) async {
    try {
      await _supabase.from('partecipazione').delete().match({'idevento': eventId, 'idutente': userId});
    } catch (e) {
      print("Errore nella rimozione del partecipante: $e");
      throw Exception("Impossibile rimuovere il partecipante.");
    }
  }

  // Nota: L'aggiunta di un partecipante richiede un'interfaccia per cercare gli utenti.
  // Per ora, implemento la funzione base.
  Future<void> addParticipant(String eventId, String userId) async {
    try {
      await _supabase.from('partecipazione').insert({'idevento': eventId, 'idutente': userId});
    } catch (e) {
      print("Errore nell'aggiunta del partecipante: $e");
      // Gestisce il caso in cui l'utente sia già iscritto (violazione primary key)
      if (e is PostgrestException && e.code == '23505') { // Codice per unique violation
        throw Exception("L'utente è già iscritto a questo evento.");
      }
      throw Exception("Impossibile aggiungere il partecipante.");
    }
  }
}

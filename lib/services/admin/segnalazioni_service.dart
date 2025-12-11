import 'package:cityclean/models/segnalazione.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SegnalazioniService {
  final SupabaseClient _supabase;

  SegnalazioniService({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  Future<List<Segnalazione>> getSegnalazioni() async {
    try {
      final response = await _supabase
          .from('segnalazione')
          .select('*, utente(email)')
          .order('ultimoaggiornamento', ascending: false); // Ordina per le più recenti

      final data = response as List;
      return data.map((json) => Segnalazione.fromJson(json)).toList();
    } catch (e) {
      print("Errore nel recupero delle segnalazioni: $e");
      throw Exception("Impossibile caricare le segnalazioni.");
    }
  }

  // Nuovo metodo per aggiornare lo stato di una segnalazione
  Future<void> updateSegnalazioneStatus(String segnalazioneId, bool approvata) async {
    try {
      await _supabase.from('segnalazione').update({
        'accettata': approvata,
        'stato': approvata ? 'approvata' : 'rifiutata', // Aggiorna anche lo stato per coerenza
      }).eq('idsegnalazione', segnalazioneId);
    } catch (e) {
      print("Errore nell'aggiornamento della segnalazione: $e");
      throw Exception("Impossibile aggiornare lo stato della segnalazione.");
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  final SupabaseClient _supabase;

  DashboardService({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  // Recupera il numero totale di utenti registrati
  Future<int> getTotalUsers() async {
    try {
      // CORREZIONE: La sintassi corretta per ottenere solo il conteggio è usare .count()
      final response = await _supabase
          .from('utente')
          .count(CountOption.exact);
      return response;
    } catch (e) {
      print("Errore nel conteggio utenti: $e");
      return 0;
    }
  }

  // Recupera il numero di segnalazioni ancora aperte
  Future<int> getOpenReportsCount() async {
    try {
      // CORREZIONE: La sintassi corretta per ottenere solo il conteggio è usare .count()
      final response = await _supabase
          .from('segnalazione')
          .count(CountOption.exact);
      return response;
    } catch (e) {
      print("Errore nel conteggio segnalazioni: $e");
      return 0;
    }
  }
  
  // TODO: Aggiungere qui altri metodi per recuperare le altre statistiche (premi, conferimenti, etc.)
}

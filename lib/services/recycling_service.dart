import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // Per debugPrint

class RecyclingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Recupera i dati grezzi. La conversione in Oggetti avviene nel Controller/Model.
  Future<List<Map<String, dynamic>>> getEcoPoints() async {
    try {
      debugPrint("♻️ RecyclingService: Inizio richiesta a Supabase...");

      final response = await _supabase
          .from('punto_raccolta')
          .select('idpuntoraccolta, nome, indirizzo, latitudine, longitudine, tipologia');

      final data = List<Map<String, dynamic>>.from(response);

      debugPrint("♻️ RecyclingService: Trovati ${data.length} punti di raccolta.");
      if (data.isNotEmpty) {
        debugPrint("♻️ Esempio primo punto: ${data.first}");
      } else {
        debugPrint("⚠️ RecyclingService: Nessun dato trovato. Controlla RLS su Supabase o se la tabella è vuota.");
      }

      return data;
    } catch (e) {
      debugPrint('❌ Errore critico recupero punti raccolta: $e');
      return [];
    }
  }
}
import 'package:supabase_flutter/supabase_flutter.dart';

class EcopointService {
  static final _supabase = Supabase.instance.client;

  /// Verifica se un Ecopoint esiste nel database dato il suo ID.
  static Future<bool> verifyEcopointExists(String ecopointId) async {
    try {
      // Esegue una query COUNT sulla tabella 'punto_raccolta'
      // Assicurati che la tabella e la colonna 'idpuntoraccolta' esistano (schema cityclean o public)
      final response = await _supabase
          .from('punto_raccolta')
          .select('idpuntoraccolta')
          .eq('idpuntoraccolta', ecopointId)
          .maybeSingle();

      // Se restituisce un dato, l'ecopoint esiste
      return response != null;
    } catch (e) {
      print("Errore verifica ecopoint: $e");
      return false;
    }
  }

  /// Recupera tutti i punti di raccolta dal database.
  static Future<List<Map<String, dynamic>>> fetchAllEcopoints() async {
    try {
      final response = await _supabase
          .from('punto_raccolta')
          .select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Errore recupero ecopoints: $e");
      return [];
    }
  }
}

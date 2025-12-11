import 'package:supabase_flutter/supabase_flutter.dart';

class ContributionService {
  static final _supabase = Supabase.instance.client;

  static Future<Map<String, dynamic>> submitContribution(String ecopointId, int points) async {
    try {
      // NOTA: Non mettiamo 'cityclean.' davanti al nome della funzione
      // perché l'abbiamo creata nello schema 'public' che è esposto di default.
      final response = await _supabase.rpc(
        'registra_conferimento_qr',
        params: {
          'p_id_punto_raccolta': ecopointId,
          'p_punti': points,
        },
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      // Pulizia messaggio errore per l'utente
      final msg = e.toString().replaceAll("PostgrestException(message: ", "").replaceAll(", code: PGRST202", "");
      return {
        'success': false,
        'message': "Errore: $msg",
      };
    }
  }
}
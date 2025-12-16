import 'package:supabase_flutter/supabase_flutter.dart';

class ContributionService {
  static final _supabase = Supabase.instance.client;

  /// Invia il conferimento includendo i Punti e il totale CO2 risparmiata.
  /// Assicurati che la funzione RPC 'registra_conferimento_qr' sul DB accetti 'p_peso_co2_totale'.
  static Future<Map<String, dynamic>> submitContribution(
      String ecopointId,
      int points,
      double totalCo2 // <-- Nuovo parametro
      ) async {
    try {
      final response = await _supabase.rpc(
        'registra_conferimento_qr',
        params: {
          'p_id_punto_raccolta': ecopointId,
          'p_punti': points,
          'p_peso_co2_totale': totalCo2, // <-- Invio del dato CO2
        },
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      // Pulizia messaggio errore per l'utente
      final msg = e.toString()
          .replaceAll("PostgrestException(message: ", "")
          .replaceAll(", code: PGRST202", "")
          .replaceAll(")", ""); // Pulizia extra

      return {
        'success': false,
        'message': "Errore: $msg",
      };
    }
  }
}
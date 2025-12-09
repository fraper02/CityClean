import 'package:cityclean/services/supabase_service.dart';
import 'package:flutter/foundation.dart';
class UtenteApi {
  /// API per recuperare i punti dell'utente corrente.
  ///
  /// Restituisce 0 se l'utente non è autenticato o se non ha un profilo.
  static Future<int> fetchUserPoints() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return 0; // Utente non autenticato
    }

    try {
      final data = await supabase
          .from('utente')
          .select('saldopunti')
          // CORREZIONE: La colonna che contiene l'ID dell'utente si chiama 'idutente'
          .eq('idutente', user.id) 
          .limit(1)
          .maybeSingle();

      if (data == null) {
        return 0; // Profilo non trovato
      }

      // Gestisce il caso in cui 'saldopunti' sia null nel database
      return (data['saldopunti'] as int?) ?? 0;
    } catch (e) {
      // In caso di errore di rete o altro, restituisce 0 e stampa l'errore
      debugPrint("Errore in fetchUserPoints: $e");
      return 0;
    }
  }
}

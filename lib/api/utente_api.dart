import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // Per accedere a `supabase`

class UtenteApi {
  /// API per recuperare i punti dell'utente corrente.
  ///
  /// Restituisce 0 se l'utente non è autenticato o se non ha un profilo.
  static Future<int> fetchUserPoints() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return 0; // Utente non autenticato
    }

    final data = await supabase
        .from('utente')
        .select('saldopunti') // Nome colonna corretto, tutto minuscolo
        .eq('id', user.id)
        .limit(1)
        .maybeSingle();

    if (data == null) {
      return 0; // Profilo non trovato
    }

    return data['saldopunti'] ?? 0;
  }
}

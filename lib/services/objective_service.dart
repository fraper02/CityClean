import 'package:cityclean/models/obiettivo.dart';
import '../main.dart'; // Per la variabile globale supabase

class ObjectiveService {
  
  /// Recupera tutti gli obiettivi e il loro stato di conseguimento per l'utente corrente.
  Future<List<Obiettivo>> getAllObjectivesWithStatus() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("Utente non autenticato.");
    }

    try {
      // Eseguiamo una LEFT JOIN per ottenere tutti gli obiettivi, arricchiti con i dati
      // di conseguimento se esistono per l'utente corrente.
      final response = await supabase
          .from('obiettivo')
          .select('*, conseguimento_obiettivo!left(*)')
          .eq('conseguimento_obiettivo.idutente', user.id);

      if ((response as List).isEmpty) {
        return [];
      }

      final objectives = (response as List).map((data) => Obiettivo.fromJson(data)).toList();
      return objectives;

    } catch (e) {
      print("Errore nel recupero degli obiettivi: $e");
      throw Exception("Impossibile caricare gli obiettivi.");
    }
  }
}

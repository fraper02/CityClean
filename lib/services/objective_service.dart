// 1. AGGIUNTO QUESTO IMPORT PER debugPrint
import 'package:flutter/foundation.dart';
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
      // Eseguiamo una LEFT JOIN per ottenere tutti gli obiettivi
      final response = await supabase
          .from('obiettivo')
          .select('*, conseguimento_obiettivo!left(*)')
          .eq('conseguimento_obiettivo.idutente', user.id);

      // In Supabase v2, response è direttamente una List<dynamic>.
      // Non serve controllare se è null.
      final List<dynamic> data = response;

      if (data.isEmpty) {
        return [];
      }

      final objectives = data.map((json) => Obiettivo.fromJson(json)).toList();
      return objectives;

    } catch (e) {
      // 2. SOSTITUITO print CON debugPrint
      debugPrint("Errore nel recupero degli obiettivi: $e");
      throw Exception("Impossibile caricare gli obiettivi.");
    }
  }
}
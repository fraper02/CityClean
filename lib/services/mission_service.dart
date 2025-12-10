import 'package:cityclean/models/missione.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // Per la variabile globale supabase

class MissionService {
  
  /// Recupera tutte le missioni e lo stato di partecipazione per l'utente corrente.
  Future<List<Missione>> getAllMissionsWithStatus() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("Utente non autenticato.");
    }

    try {
      // 1. Recupera tutte le missioni disponibili, includendo i dati del badge premio.
      final missionsResponse = await supabase
          .from('missione')
          .select('*, id_badge_premio(*)');
      
      // 2. Recupera tutte le partecipazioni dell'utente corrente.
      final participationsResponse = await supabase
          .from('partecipazione_missione')
          .select('*')
          .eq('id_utente', user.id);

      // 3. Mappa le partecipazioni per un accesso veloce basato sull'ID della missione.
      final participationsMap = {
        for (var p in participationsResponse) p['id_missione']: p
      };
      
      // 4. Combina i dati: per ogni missione, aggiungi i dati di partecipazione se esistono.
      final missions = (missionsResponse as List).map((missionJson) {
        final missionId = missionJson['id_missione'];
        if (participationsMap.containsKey(missionId)) {
          // Inietta i dati di partecipazione nel JSON della missione.
          missionJson['partecipazione_missione'] = [participationsMap[missionId]];
        } else {
          // Se non c'è partecipazione, inietta una lista vuota.
          missionJson['partecipazione_missione'] = [];
        }
        // Crea l'oggetto Missione usando la factory, che ora può gestire entrambi i casi.
        return Missione.fromJson(missionJson);
      }).toList();

      return missions;

    } catch (e) {
      print("Errore nel recupero delle missioni: $e");
      throw Exception("Impossibile caricare le missioni.");
    }
  }

  /// Iscrive l'utente a una nuova missione.
  Future<void> acceptMission(String missionId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato per accettare la missione.");

    try {
      await supabase.from('partecipazione_missione').insert({
        'id_utente': user.id,
        'id_missione': missionId,
      });
    } catch (e) {
      print("Errore durante l'accettazione della missione: $e");
      if (e is PostgrestException && e.code == '23505') {
        // L'utente sta già partecipando, non è un errore critico.
        print("L'utente sta già partecipando a questa missione.");
        return; 
      }
      throw Exception("Impossibile partecipare alla missione.");
    }
  }
}

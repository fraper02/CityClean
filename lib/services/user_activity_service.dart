import 'package:cityclean/models/user_activity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserActivityService {
  final SupabaseClient _supabase;

  UserActivityService({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  Future<List<UserActivity>> getCurrentUserActivity() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception("Nessun utente autenticato per recuperare lo storico attività.");
    }
    final userId = user.id;

    try {
      final results = await Future.wait([
        _supabase.from('conferimento').select('*, punto_raccolta:id_punto_raccolta(nome)').eq('id_utente', userId),
        _supabase.from('partecipazione_missione').select('*, missione:id_missione(titolo, badge_premio:id_badge_premio(nome))').eq('id_utente', userId).eq('stato', 'COMPLETATA'),
        _supabase.from('conseguimento_obiettivo').select('*, obiettivo:idobiettivo(nome, punti_ricompensa)').eq('idutente', userId),
        // CORREZIONE DEFINITIVA: `puntiUtilizzati` viene selezionato dalla tabella `possesso_premio` (con il *), non dalla join con `premio`.
        _supabase.from('possesso_premio').select('*, premio:idpremio(nome)').eq('idutente', userId),
      ]);

      final List<UserActivity> activities = [];

      // Conferimenti
      for (var item in (results[0] as List)) {
        if (item['data_conferimento'] != null) {
          activities.add(UserActivity(
            id: item['id'].toString(),
            type: ActivityType.conferimento,
            date: DateTime.parse(item['data_conferimento']),
            description: 'Conferimento presso ${item['punto_raccolta']?['nome'] ?? 'N/D'}',
            points: item['punti_guadagnati'],
          ));
        }
      }

      // Missioni completate
      for (var item in (results[1] as List)) {
        if (item['data_completamento'] != null) {
          activities.add(UserActivity(
            id: '${item['id_utente']}-${item['id_missione']}',
            type: ActivityType.missione,
            date: DateTime.parse(item['data_completamento']),
            description: 'Missione: ${item['missione']?['titolo'] ?? 'N/D'}',
            badgeName: item['missione']?['badge_premio']?['nome'] ?? 'N/D',
          ));
        }
      }

      // Obiettivi conseguiti
      for (var item in (results[2] as List)) {
        if (item['data_completamento'] != null) {
          activities.add(UserActivity(
            id: '${item['idutente']}-${item['idobiettivo']}',
            type: ActivityType.obiettivo,
            date: DateTime.parse(item['data_completamento']),
            description: 'Obiettivo: ${item['obiettivo']?['nome'] ?? 'N/D'}',
            points: item['punti_guadagnati'],
          ));
        }
      }
      
      // Premi riscattati
      for (var item in (results[3] as List)) {
        if (item['dataAcquisizione'] != null) {
          activities.add(UserActivity(
            id: item['idacquisto'].toString(),
            type: ActivityType.premio,
            date: DateTime.parse(item['dataAcquisizione']),
            description: 'Premio: ${item['premio']?['nome'] ?? 'N/D'}',
            points: -(item['puntiUtilizzati'] as int? ?? 0),
          ));
        }
      }
      
      activities.sort((a, b) => b.date.compareTo(a.date));

      return activities;

    } catch (e) {
      print("Errore nel recupero dello storico attività utente: $e");
      throw Exception("Impossibile caricare il tuo storico attività.");
    }
  }
}

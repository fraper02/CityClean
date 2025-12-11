import 'package:cityclean/models/user_activity.dart';
import 'package:cityclean/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUsersService {
  final SupabaseClient _supabase;

  AdminUsersService({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  Future<List<UserProfile>> getUsersWithStats() async {
    try {
      final usersResponse = await _supabase.from('utente').select();
      final conferimentiResponse = await _supabase.from('conferimento').select('id_utente');
      final eventsResponse = await _supabase.from('partecipazione').select('idutente');

      final usersData = usersResponse as List;
      final conferimenti = conferimentiResponse as List;
      final events = eventsResponse as List;

      final conferimentiCounts = <String, int>{};
      for (var c in conferimenti) {
        conferimentiCounts.update(c['id_utente'], (value) => value + 1, ifAbsent: () => 1);
      }

      final eventsCounts = <String, int>{};
      for (var e in events) {
        eventsCounts.update(e['idutente'], (value) => value + 1, ifAbsent: () => 1);
      }

      return usersData.map((userData) {
        final user = UserProfile.fromJson(userData);
        final userConferimenti = conferimentiCounts[user.id] ?? 0;
        final userEvents = eventsCounts[user.id] ?? 0;
        return user.withStats(conferimenti: userConferimenti, events: userEvents);
      }).toList();

    } catch (e) {
      print("Errore nel recupero degli utenti con statistiche: $e");
      throw Exception("Impossibile caricare i dati degli utenti.");
    }
  }

  Future<void> addPointsToUser(String userId, int points, String description) async {
    try {
      // CORREZIONE: Rimosso lo schema duplicato. Il client Supabase è già configurato con lo schema 'cityclean'.
      await _supabase.rpc('add_user_points', params: {
        'p_id_utente': userId,
        'p_punti': points,
        'p_descrizione': description
      });
    } catch (e) {
      print("Errore durante l'assegnazione dei punti: $e");
      throw Exception('Impossibile assegnare i punti. Verifica che la funzione `add_user_points(p_id_utente, p_punti, p_descrizione)` esista e che i permessi siano corretti.');
    }
  }

  Future<List<UserActivity>> getUserActivity(String userId) async {
    try {
      final results = await Future.wait([
        _supabase.from('conferimento').select('*, punto_raccolta:id_punto_raccolta(nome)').eq('id_utente', userId),
        _supabase.from('partecipazione_missione').select('*, missione:id_missione(titolo, badge_premio:id_badge_premio(nome))').eq('id_utente', userId).eq('stato', 'COMPLETATA'),
        _supabase.from('conseguimento_obiettivo').select('*, obiettivo:idobiettivo(nome, punti_ricompensa)').eq('idutente', userId),
        _supabase.from('possesso_premio').select('*, premio:idpremio(nome)').eq('idutente', userId),
        _supabase.from('storico_punti_manuali').select().eq('id_utente', userId),
      ]);

      final List<UserActivity> activities = [];

      for (var item in (results[0] as List)) { if (item['data_conferimento'] != null) activities.add(UserActivity(id: item['id'].toString(), type: ActivityType.conferimento, date: DateTime.parse(item['data_conferimento']), description: 'Conferimento presso ${item['punto_raccolta']?['nome'] ?? 'N/D'}', points: item['punti_guadagnati']));}
      for (var item in (results[1] as List)) { if (item['data_completamento'] != null) activities.add(UserActivity(id: '${item['id_utente']}-${item['id_missione']}', type: ActivityType.missione, date: DateTime.parse(item['data_completamento']), description: 'Missione: ${item['missione']?['titolo'] ?? 'N/D'}', badgeName: item['missione']?['badge_premio']?['nome'] ?? 'N/D'));}
      for (var item in (results[2] as List)) { if (item['data_completamento'] != null) activities.add(UserActivity(id: '${item['idutente']}-${item['idobiettivo']}', type: ActivityType.obiettivo, date: DateTime.parse(item['data_completamento']), description: 'Obiettivo: ${item['obiettivo']?['nome'] ?? 'N/D'}', points: item['punti_guadagnati']));}
      for (var item in (results[3] as List)) { if (item['dataAcquisizione'] != null) activities.add(UserActivity(id: item['idacquisto'].toString(), type: ActivityType.premio, date: DateTime.parse(item['dataAcquisizione']), description: 'Premio: ${item['premio']?['nome'] ?? 'N/D'}', points: -(item['puntiUtilizzati'] as int? ?? 0)));}
      for (var item in (results[4] as List)) { if (item['data_operazione'] != null) activities.add(UserActivity(id: item['id'].toString(), type: ActivityType.adminAdjustment, date: DateTime.parse(item['data_operazione']), description: 'Admin: ${item['descrizione'] ?? 'Aggiustamento manuale'}', points: item['punti_assegnati']));}
      
      activities.sort((a, b) => b.date.compareTo(a.date));

      return activities;

    } catch (e) {
      print("Errore nel recupero dello storico attività: $e");
      throw Exception("Impossibile caricare lo storico dell'utente.");
    }
  }
}

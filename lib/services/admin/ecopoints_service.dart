import 'package:cityclean/models/eco_point_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EcopointsService {
  final SupabaseClient _supabase;

  EcopointsService({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  /// Recupera la lista degli ecopunti completa di statistiche.
  /// Chiama la RPC `get_ecopoints_with_stats` su Supabase invece della tabella grezza.
  Future<List<Ecopoint>> getEcopoints() async {
    try {
      // MODIFICA: Usiamo .rpc per ottenere i dati aggregati dalla funzione SQL
      // La funzione restituisce: idpuntoraccolta, nome..., monthly_conferimenti_count, monthly_unique_users
      final response = await _supabase.rpc('get_ecopoints_with_stats');

      return (response as List).map((item) => Ecopoint.fromJson(item)).toList();
    } catch (e) {
      print("Errore RPC get_ecopoints_with_stats: $e");
      throw Exception("Impossibile caricare i punti di raccolta con le statistiche. Verifica che la funzione `get_ecopoints_with_stats` sia pubblicata su Supabase.");
    }
  }

  Future<void> createEcopoint(Ecopoint ecopoint) async {
    try {
      final data = ecopoint.toJson();
      // PULIZIA: Rimuoviamo i campi statistici calcolati (read-only) prima di scrivere nella tabella fisica
      _removeStatsFields(data);

      await _supabase.from('punto_raccolta').insert(data);
    } catch (e) {
      throw Exception("Impossibile creare il punto di raccolta: $e");
    }
  }

  Future<void> updateEcopoint(Ecopoint ecopoint) async {
    try {
      final data = ecopoint.toJson();
      // PULIZIA: Rimuoviamo i campi statistici calcolati (read-only) prima di aggiornare la tabella fisica
      _removeStatsFields(data);

      await _supabase.from('punto_raccolta').update(data).eq('idpuntoraccolta', ecopoint.id);
    } catch (e) {
      throw Exception("Impossibile aggiornare il punto di raccolta: $e");
    }
  }

  Future<void> deleteEcopoint(String id) async {
    try {
      await _supabase.from('punto_raccolta').delete().eq('idpuntoraccolta', id);
    } catch (e) {
      throw Exception("Impossibile eliminare il punto di raccolta: $e");
    }
  }

  // Helper per pulire il JSON dai campi che esistono solo nella vista/funzione ma non nella tabella
  void _removeStatsFields(Map<String, dynamic> data) {
    data.remove('monthly_conferimenti_count');
    data.remove('monthly_unique_users');
    data.remove('monthly_total_punti');
    // Rimuovi anche le varianti camelCase se il tuo modello le genera
    data.remove('monthlyConferimentiCount');
    data.remove('monthlyUniqueUsers');
    data.remove('monthlyTotalPunti');
  }
}
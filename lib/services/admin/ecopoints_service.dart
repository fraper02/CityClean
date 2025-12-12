import 'package:cityclean/models/eco_point_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EcopointsService {
  final SupabaseClient _supabase;

  EcopointsService({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  Future<List<Ecopoint>> getEcopoints() async {
    try {
      final response = await _supabase.from('punto_raccolta').select();
      return (response as List).map((item) => Ecopoint.fromJson(item)).toList();
    } catch (e) {
      print("Errore RPC get_ecopoints_with_stats: $e");
      throw Exception("Impossibile caricare i punti di raccolta. Assicurati che la funzione `get_ecopoints_with_stats` esista, che i permessi siano corretti e che lo schema del client Supabase sia configurato correttamente.");
    }
  }

  Future<void> createEcopoint(Ecopoint ecopoint) async {
    try {
      final data = ecopoint.toJson();
      await _supabase.from('punto_raccolta').insert(data);
    } catch (e) {
      throw Exception("Impossibile creare il punto di raccolta: $e");
    }
  }

  Future<void> updateEcopoint(Ecopoint ecopoint) async {
    try {
      final data = ecopoint.toJson();
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
}

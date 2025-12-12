import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/eco_point_model.dart';

class RecyclingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- ECO POINTS ---
  Future<List<Map<String, dynamic>>> getEcoPoints() async {
    try {
      final response = await _supabase
          .from('punto_raccolta')
          .select('idpuntoraccolta, nome, indirizzo, latitudine, longitudine, tipologia');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Errore recupero punti: $e');
      return [];
    }
  }

  Future<bool> createEcoPoint({
    required String name,
    required String address,
    required String type,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final Map<String, dynamic> dataToInsert = {
        'nome': name,
        'indirizzo': address,
        'tipologia': type,
        'latitudine': latitude,
        'longitudine': longitude,
      };
      await _supabase.from('punto_raccolta').insert(dataToInsert);
      return true;
    } catch (e) {
      debugPrint("Errore inserimento Eco Point: $e");
      return false;
    }
  }

  // --- PARTNER (NUOVO) ---
  Future<List<Map<String, dynamic>>> getPartners() async {
    try {
      // Recuperiamo tutti i campi dei partner
      final response = await _supabase.from('partner').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Errore recupero partner: $e');
      return [];
    }
  }
}
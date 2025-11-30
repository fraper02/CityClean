// lib/dao/prize_possession_dao.dart

import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrizePossessionDAO {
  final SupabaseClient _supabase;
  PrizePossessionDAO({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  Future<void> create(String userId, String prizeId) async {
    await _supabase.from('possesso_premio').insert({
      'idutente': userId,
      'idpremio': prizeId,
      'dataAcquisizione': DateTime.now().toIso8601String(),
    });
  }

  /// RECUPERA LA CRONOLOGIA DEI PREMI RISCATTATI PER L'UTENTE CORRENTE
  Future<List<Map<String, dynamic>>> getHistory(String userId) async {
    try {
      final response = await _supabase
          .from('possesso_premio')
          .select('''
                dataAcquisizione,
                premio (
                  nome,
                  costopunti
                )
              ''')
          .eq('idutente', userId)
          .order('dataAcquisizione', ascending: false); // Ordina per i più recenti

      return List<Map<String, dynamic>>.from(response);

    } on PostgrestException catch (e) {
      log("DAO Error - getHistory: ${e.message}");
      throw Exception("Errore nel recupero della cronologia premi.");
    } catch (e) {
      log("DAO Generic Error - getHistory: $e");
      throw Exception("Si è verificato un errore imprevisto.");
    }
  }
}
    
// lib/services/redeem_service.dart

import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prizes.dart';
import '../models/userProfile.dart';

class RedeemService {
  final SupabaseClient _supabase;

  RedeemService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<Map<String, dynamic>> loadRewardsScreenData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato.");

    try {
      final results = await Future.wait([
        UserProfile.getPoints(user.id),
        Prize.fetchAll(),
      ]);
      return {
        'userPoints': results[0] as int,
        'availablePrizes': results[1] as List<Prize>,
      };
    } catch (e) {
      log('Errore in RedeemService.loadRewardsScreenData: $e');
      throw Exception('Impossibile caricare i dati dei premi.');
    }
  }

  Future<void> redeemPrize(Prize prize) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato.");

    // Controlli UI (la sicurezza vera è nel DB)
    final currentUserPoints = await UserProfile.getPoints(user.id);
    if (prize.quantitaDisponibile <= 0) throw Exception('Premio esaurito.');
    if (currentUserPoints < prize.costoPunti) throw Exception('Punti insufficienti.');

    try {
      // CHIAMATA RPC CORRETTA
      // Chiama la funzione 'riscatta_premio' (che ora è in public, quindi visibile)
      final response = await _supabase.rpc(
        'riscatta_premio',
        params: {
          'p_id_premio': prize.id,
          'p_id_utente': user.id,
        },
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'Errore sconosciuto');
      }

      log("Riscatto OK: ${result['message']}");

    } catch (e) {
      log("Errore riscatto: $e");
      // Puliamo il messaggio d'errore
      final msg = e.toString().replaceAll("Exception: ", "").replaceAll("PostgrestException(message: ", "");
      throw Exception(msg);
    }
  }
}
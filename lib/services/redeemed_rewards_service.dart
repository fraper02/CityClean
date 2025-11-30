// lib/services/redeemed_rewards_service.dart
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
// 1. Rimuovi il DAO e importa i modelli necessari
import '../models/prize_possession.dart';
import '../models/redeemed_reward.dart';

/// Service per gestire la logica relativa ai premi già riscattati.
class RedeemedRewardsService {
  // 2. Rimuovi la dipendenza dal DAO
  final SupabaseClient _supabase;

  RedeemedRewardsService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Carica e processa la cronologia dei premi riscattati.
  Future<List<RedeemedReward>> getRedeemedRewards() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato.");

    // 3. Chiama direttamente il metodo statico definito nel modello.
    // Il modello ora è responsabile sia della chiamata al DB che della trasformazione dei dati.
    try {
      return await PrizePossession.fetchHistory(user.id);
    } catch (e) {
      log("Errore in RedeemedRewardsService: $e");
      // Rilancia l'eccezione per farla gestire dal controller/UI
      rethrow;
    }
  }
}

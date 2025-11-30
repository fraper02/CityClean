// lib/services/redeemed_rewards_service.dart
import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../dao/prize_possession_dao.dart';
import '../models/redeemed_reward.dart';

/// Service per gestire la logica relativa ai premi già riscattati.
class RedeemedRewardsService {
  final PrizePossessionDAO _dao;
  final SupabaseClient _supabase;

  RedeemedRewardsService({PrizePossessionDAO? dao, SupabaseClient? supabase})
      : _dao = dao ?? PrizePossessionDAO(),
        _supabase = supabase ?? Supabase.instance.client;

  /// Carica e processa la cronologia dei premi riscattati.
  Future<List<RedeemedReward>> getRedeemedRewards() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato.");

    // 1. Ottiene i dati grezzi dal DAO
    final rawDataList = await _dao.getHistory(user.id);

    // 2. Trasforma i dati grezzi in una lista di modelli per la UI
    final List<RedeemedReward> redeemedList = [];
    for (final rawData in rawDataList) {
      try {
        final prizeDetails = rawData['premio'] as Map<String, dynamic>?;

        if (prizeDetails != null) {
          redeemedList.add(
            RedeemedReward(
              title: prizeDetails['nome'] ?? 'Nome non disponibile',
              points: prizeDetails['costopunti'] ?? 0,
              date: DateTime.parse(rawData['dataAcquisizione']),
            ),
          );
        }
      } catch (e) {
        log("Service Error - getRedeemedRewards: Failed to parse item $rawData. Error: $e");
        // Ignora l'elemento malformato per non bloccare la UI
      }
    }

    return redeemedList;
  }
}

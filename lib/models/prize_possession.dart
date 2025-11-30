// lib/models/prize_possession.dart
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'redeemed_reward.dart'; // Importa il modello per la UI

class PrizePossession {
  // ... (proprietà, costruttore, fromJson e toJson invariati) ...
  final String idRiscatto;
  final String userId;
  final String prizeId;
  final DateTime acquiredAt;

  PrizePossession({
    required this.idRiscatto,
    required this.userId,
    required this.prizeId,
    required this.acquiredAt,
  });

  factory PrizePossession.fromJson(Map<String, dynamic> json) {
    return PrizePossession(
      idRiscatto: json['idRiscatto'],
      userId: json['idutente'],
      prizeId: json['idpremio'],
      acquiredAt: DateTime.parse(json['dataAcquisizione']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRiscatto': idRiscatto,
      'idutente': userId,
      'idpremio': prizeId,
      'dataAcquisizione': acquiredAt.toIso8601String(),
    };
  }

  // --- LOGICA DAO INTEGRATA ---
  static final _supabase = Supabase.instance.client;

  /// Crea un nuovo record di possesso premio.
  static Future<void> create(String userId, String prizeId) async {
    await _supabase.from('possesso_premio').insert({
      'idutente': userId,
      'idpremio': prizeId,
      'dataAcquisizione': DateTime.now().toIso8601String(),
    });
  }

  // ---------- CORREZIONE QUI: AGGIUNGI QUESTO METODO ----------
  /// Recupera la cronologia dei premi riscattati per un utente,
  /// già trasformata nel modello `RedeemedReward` per la UI.
  static Future<List<RedeemedReward>> fetchHistory(String userId) async {
    try {
      final response = await _supabase
          .from('possesso_premio')
          .select('dataAcquisizione, premio (nome, costopunti)')
          .eq('idutente', userId)
          .order('dataAcquisizione', ascending: false);

      final List<RedeemedReward> redeemedList = [];
      for (final rawData in response) {
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
      }
      return redeemedList;
    } catch (e) {
      log("Errore in PrizePossession.fetchHistory: $e");
      throw Exception("Impossibile recuperare la cronologia.");
    }
  }
// -----------------------------------------------------------------
}

// lib/models/prize_possession.dart
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'redeemed_reward.dart'; // Importa il modello per la UI

class PrizePossession {
  final String idAcquisto; // Corretto da idRiscatto a idAcquisto
  final String userId;
  final String prizeId;
  final DateTime acquiredAt;
  final int puntiUtilizzati; // Aggiunto campo

  PrizePossession({
    required this.idAcquisto,
    required this.userId,
    required this.prizeId,
    required this.acquiredAt,
    required this.puntiUtilizzati, // Aggiunto campo
  });

  // Factory e toJson non sono usati direttamente dalla logica di riscatto/visualizzazione,
  // ma li aggiorniamo per coerenza.
  factory PrizePossession.fromJson(Map<String, dynamic> json) {
    return PrizePossession(
      idAcquisto: json['idacquisto'], // Corretto
      userId: json['idutente'],
      prizeId: json['idpremio'],
      acquiredAt: DateTime.parse(json['dataAcquisizione']),
      puntiUtilizzati: json['puntiUtilizzati'] ?? 0, // Aggiunto
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idacquisto': idAcquisto,
      'idutente': userId,
      'idpremio': prizeId,
      'dataAcquisizione': acquiredAt.toIso8601String(),
      'puntiUtilizzati': puntiUtilizzati, // Aggiunto
    };
  }

  // --- LOGICA DAO INTEGRATA ---
  static final _supabase = Supabase.instance.client;

  /// Crea un nuovo record di possesso premio, salvando i punti utilizzati.
  static Future<void> create(String userId, String prizeId, int puntiUtilizzati) async {
    await _supabase.from('possesso_premio').insert({
      'idutente': userId,
      'idpremio': prizeId,
      'puntiUtilizzati': puntiUtilizzati, // Ecco il campo chiave
      'dataAcquisizione': DateTime.now().toIso8601String(),
    });
  }

  /// Recupera la cronologia dei premi riscattati per un utente.
  /// Ora legge i punti dalla cronologia e non dal premio attuale.
  static Future<List<RedeemedReward>> fetchHistory(String userId) async {
    try {
      // Selezioniamo 'puntiUtilizzati' dalla tabella 'possesso_premio'
      // e solo il nome del premio dalla tabella collegata.
      final response = await _supabase
          .from('possesso_premio')
          .select('dataAcquisizione, puntiUtilizzati, premio (nome)')
          .eq('idutente', userId)
          .order('dataAcquisizione', ascending: false);

      final List<RedeemedReward> redeemedList = [];
      for (final rawData in response) {
        final prizeDetails = rawData['premio'] as Map<String, dynamic>?;

        // Se il premio è stato cancellato (prizeDetails == null),
        // mostriamo comunque la transazione.
        redeemedList.add(
          RedeemedReward(
            title: prizeDetails?['nome'] ?? 'Premio non più disponibile',
            // Usiamo 'puntiUtilizzati' direttamente dal record di possesso.
            points: rawData['puntiUtilizzati'] as int,
            date: DateTime.parse(rawData['dataAcquisizione']),
          ),
        );
      }
      return redeemedList;
    } catch (e) {
      log("Errore in PrizePossession.fetchHistory: $e");
      throw Exception("Impossibile recuperare la cronologia.");
    }
  }
}

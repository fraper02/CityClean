// lib/services/redeem_service.dart

import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prizes.dart';
import '../models/prize_possession.dart';
import '../models/userProfile.dart';

/// Service che orchestra la logica di business per il riscatto dei premi.
/// Interagisce direttamente con i metodi statici dei modelli (Active Record pattern).
class RedeemService {
  final SupabaseClient _supabase;

  // Il costruttore non ha più bisogno di iniettare i DAO.
  RedeemService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Carica i dati necessari per la schermata (punti utente e premi).
  Future<Map<String, dynamic>> loadRewardsScreenData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato.");

    try {
      // CORREZIONE: Usa la classe UserProfile importata
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

  /// Orchestra l'operazione di riscatto premio.
  Future<void> redeemPrize(Prize prize) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato.");

    // Recupera i punti freschi prima di ogni transazione.
    // CORREZIONE: Usa la classe UserProfile importata
    final currentUserPoints = await UserProfile.getPoints(user.id);

    // Controlli di business logic
    if (prize.quantitaDisponibile <= 0) throw Exception('Premio esaurito.');
    if (currentUserPoints < prize.costoPunti) throw Exception('Punti insufficienti.');

    try {
      final newPoints = currentUserPoints - prize.costoPunti;
      final newQuantity = prize.quantitaDisponibile - 1;

      // Esegue le operazioni di scrittura tramite i metodi statici dei modelli.
      // CORREZIONE: Usa la classe UserProfile importata
      await Future.wait([
        UserProfile.updatePoints(user.id, newPoints),
        Prize.updateQuantity(prize.id, newQuantity),
        PrizePossession.create(user.id, prize.id),
      ]);
    } catch (e) {
      log("Errore durante la transazione di riscatto: $e");
      throw Exception("L'operazione di riscatto è fallita. Riprova.");
    }
  }
}

// lib/services/redeem_service.dart

import 'dart:developer';// CORREZIONE: Usa il nome file corretto in snake_case.
import 'package:cityclean/dao/prize_dao.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dao/prize_possession_dao.dart';
import '../dao/user_dao.dart';
import '../models/prizes.dart';

// ... il resto della classe RedeemService rimane invariato ...
class RedeemService {
  final UserDAO _userDAO;
  final PrizeDAO _prizeDAO;
  final PrizePossessionDAO _possessionDAO;
  final SupabaseClient _supabase;

  RedeemService({UserDAO? userDAO, PrizeDAO? prizeDAO, PrizePossessionDAO? possessionDAO, SupabaseClient? supabase})
      : _userDAO = userDAO ?? UserDAO(),
        _prizeDAO = prizeDAO ?? PrizeDAO(),
        _possessionDAO = possessionDAO ?? PrizePossessionDAO(),
        _supabase = supabase ?? Supabase.instance.client;

  /// Carica i dati necessari per la schermata (punti utente e premi).
  Future<Map<String, dynamic>> loadRewardsScreenData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato.");

    try {
      final results = await Future.wait([
        _userDAO.getUserPoints(user.id),
        _prizeDAO.getAvailablePrizes(),
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

    final currentUserPoints = await _userDAO.getUserPoints(user.id);

    if (prize.quantitaDisponibile <= 0) throw Exception('Premio esaurito.');
    if (currentUserPoints < prize.costoPunti) throw Exception('Punti insufficienti.');

    try {
      final newPoints = currentUserPoints - prize.costoPunti;
      final newQuantity = prize.quantitaDisponibile - 1;

      // Esegue le operazioni di scrittura tramite i rispettivi DAO
      await Future.wait([
        _userDAO.updateUserPoints(user.id, newPoints),
        _prizeDAO.updatePrizeQuantity(prize.id, newQuantity),
        _possessionDAO.create(user.id, prize.id),
      ]);
    } catch (e) {
      log("Errore durante la transazione di riscatto: $e");
      throw Exception("L'operazione di riscatto è fallita. Riprova.");
    }
  }
}

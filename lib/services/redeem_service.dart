import 'dart:developer';
import 'package:cityclean/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prizes.dart';
import '../services/user_service.dart';
import '../main.dart';
import '../services/notifiche.dart'; // 👈 aggiungi questo


class RedeemService {
  Future<Map<String, dynamic>> loadRewardsScreenData() async {
    final user = supabase.auth.currentUser;
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
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato.");

    final currentUserPoints = await UserProfile.getPoints(user.id);
    if (prize.quantitaDisponibile <= 0) throw Exception('Premio esaurito.');
    if (currentUserPoints < prize.costoPunti) throw Exception('Punti insufficienti.');

    try {
      final response = await supabase.rpc(
        'riscatta_premio',
        params: {
          'p_id_premio': prize.id,
          'p_id_utente': user.id,
        },
      );

      final result = response as Map<String, dynamic>?;

      if (result?['success'] != true) {
        throw Exception(result?['message'] ?? 'Errore sconosciuto');
      }

      log("Riscatto OK: ${result?['message']}");

      await NotificheService.premioRiscattato(
        nomePremio: prize.id
      );

    } catch (e) {
      log("Errore riscatto: $e");
      final msg = e.toString().replaceAll("Exception: ", "").replaceAll("PostgrestException(message: ", "");
      throw Exception(msg);
    }
  }
}
// lib/dao/prize_dao.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prizes.dart';

/// DAO (Data Access Object) per il modello Prize.
/// Si occupa esclusivamente dell'interazione diretta con la tabella 'premio'.
class PrizeDAO {
  final SupabaseClient _supabase;

  PrizeDAO({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  /// Recupera la lista di tutti i premi disponibili dal database.
  /// Restituisce una lista di oggetti Prize.
  Future<List<Prize>> getAvailablePrizes() async {
    final response = await _supabase.from('premio').select();
    
    final List<Prize> prizeList = [];
    for (final item in response) {
      prizeList.add(Prize.fromJson(item));
    }
    return prizeList;
  }

  /// Aggiorna la quantità disponibile di un singolo premio.
  Future<void> updatePrizeQuantity(String prizeId, int newQuantity) async {
    await _supabase
        .from('premio')
        .update({'quantitadisponibile': newQuantity})
        .eq('idpremio', prizeId);
  }
}

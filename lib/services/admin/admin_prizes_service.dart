import 'package:cityclean/models/partner.dart';
import 'package:cityclean/models/prizes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPrizesService {
  final SupabaseClient _supabase;

  AdminPrizesService({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  // --- GESTIONE PREMI ---

  Future<List<Prize>> getPrizes() async {
    try {
      // Facciamo una JOIN per includere anche i dati del partner
      final response = await _supabase.from('premio').select('*, partner:idpartner(*)');
      return (response as List).map((item) => Prize.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Impossibile caricare i premi: $e");
    }
  }

  Future<void> createPrize(Prize prize) async {
    try {
      await _supabase.from('premio').insert(prize.toJson());
    } catch (e) {
      throw Exception("Impossibile creare il premio: $e");
    }
  }

  Future<void> updatePrize(Prize prize) async {
    try {
      await _supabase.from('premio').update(prize.toJson()).eq('idpremio', prize.id);
    } catch (e) {
      throw Exception("Impossibile aggiornare il premio: $e");
    }
  }

  Future<void> deletePrize(String id) async {
    try {
      await _supabase.from('premio').delete().eq('idpremio', id);
    } catch (e) {
      throw Exception("Impossibile eliminare il premio: $e");
    }
  }

  // --- GESTIONE PARTNER ---

  Future<List<Partner>> getPartners() async {
    try {
      final response = await _supabase.from('partner').select();
      return (response as List).map((item) => Partner.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Impossibile caricare i partner: $e");
    }
  }

  Future<void> createPartner(Partner partner) async {
    try {
      await _supabase.from('partner').insert(partner.toJson());
    } catch (e) {
      throw Exception("Impossibile creare il partner: $e");
    }
  }

  Future<void> updatePartner(Partner partner) async {
    try {
      await _supabase.from('partner').update(partner.toJson()).eq('idpartner', partner.id);
    } catch (e) {
      throw Exception("Impossibile aggiornare il partner: $e");
    }
  }

  Future<void> deletePartner(String id) async {
    try {
      await _supabase.from('partner').delete().eq('idpartner', id);
    } catch (e) {
      throw Exception("Impossibile eliminare il partner: $e");
    }
  }
}

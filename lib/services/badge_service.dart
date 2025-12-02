import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/badge.dart';

class BadgeService {
  final SupabaseClient _supabase;

  BadgeService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<List<Badge>> getBadgesWithUnlockStatus() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato.");

    try {
      final responses = await Future.wait([
        _supabase.from('badge').select(),
        _supabase.from('possesso_badge').select('idbadge').eq('idutente', user.id),
      ]);

      final allBadgesResponse = responses[0] as List<dynamic>;
      final userBadgesResponse = responses[1] as List<dynamic>;

      if (allBadgesResponse.isEmpty) {
        return [];
      }

      final allBadges = allBadgesResponse.map((data) => Badge.fromJson(data)).toList();
      final unlockedBadgeIds = userBadgesResponse.map((data) => data['idbadge'] as String).toSet();

      final badgeListWithStatus = allBadges.map((badge) {
        return badge.copyWith(isUnlocked: unlockedBadgeIds.contains(badge.id));
      }).toList();

      return badgeListWithStatus;

    } catch (e) {
      log("Errore in BadgeService.getBadgesWithUnlockStatus: $e");
      throw Exception("Impossibile caricare i dati dei badge.");
    }
  }
}

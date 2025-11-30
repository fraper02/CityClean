// lib/dao/user_dao.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDAO {
  final SupabaseClient _supabase;
  UserDAO({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  Future<int> getUserPoints(String userId) async {
    final response = await _supabase
        .from('utente')
        .select('saldopunti')
        .eq('idutente', userId)
        .single();
    return response['saldopunti'] as int;
  }

  Future<void> updateUserPoints(String userId, int newPoints) async {
    await _supabase
        .from('utente')
        .update({'saldopunti': newPoints})
        .eq('idutente', userId);
  }
}

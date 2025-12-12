import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sessione_raccolta.dart';

class RecyclingService {
  static final RecyclingService _instance = RecyclingService._internal();
  factory RecyclingService() => _instance;
  RecyclingService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  static const _key = 'recycling_start_time';

  Future<void> startRecycling() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, DateTime.now().toIso8601String());
  }

  Future<Duration> stopRecycling() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeString = prefs.getString(_key);

    if (startTimeString == null) {
      return Duration.zero;
    }

    await prefs.remove(_key);
    final startTime = DateTime.parse(startTimeString);
    return DateTime.now().difference(startTime);
  }

  Future<bool> isRecycling() async {
    final prefs = await SharedPreferences.getInstance();
    // Force a reload of the data from disk to prevent reading cached values.
    await prefs.reload();
    return prefs.containsKey(_key);
  }

  Future<void> createSessioneRaccolta(SessioneRaccolta sessione) async {
    try {
      await _supabase.from('sessione_raccolta').insert(sessione.toJson());
    } on PostgrestException catch (error) {
      throw Exception('Database error: ${error.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

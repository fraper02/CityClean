import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class RecyclingService {
  static final RecyclingService _instance = RecyclingService._internal();
  factory RecyclingService() => _instance;
  RecyclingService._internal();

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
}

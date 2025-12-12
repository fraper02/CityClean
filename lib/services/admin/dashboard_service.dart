import 'package:supabase_flutter/supabase_flutter.dart';

// Enum per definire l'intervallo di tempo per le statistiche
enum StatsTimeRange { month, year, allTime }

class DashboardService {
  final SupabaseClient _supabase;

  DashboardService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  // Metodo UNICO che chiama la nuova, potente funzione SQL
  Future<Map<String, dynamic>> fetchDashboardData({StatsTimeRange range = StatsTimeRange.allTime}) async {
    final rangeString = range.toString().split('.').last;

    try {
      final data = await _supabase.rpc(
        'get_admin_dashboard_data',
        params: {'p_range': rangeString},
      );
      return data as Map<String, dynamic>;
    } catch (e) {
      // MODIFICA: Invece di restituire dati vuoti, rilanciamo l'eccezione.
      // Questo farà apparire il vero errore del database nella UI.
      print("Errore grave nella chiamata RPC 'get_admin_dashboard_data': $e");
      throw Exception("Errore dal database: ${e.toString()}");
    }
  }
}

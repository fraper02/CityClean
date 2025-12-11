import 'package:cityclean/models/sessione_raccolta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessioneRaccoltaService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createSessioneRaccolta(SessioneRaccolta sessione) async {
    try {
      await _supabase.from('sessione_raccolta').insert(sessione.toJson());
    } on PostgrestException catch (error) {
      throw Exception(error.message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

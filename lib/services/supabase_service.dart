import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Privato constructor
  SupabaseService._();

  // Singleton instance
  static final SupabaseService _instance = SupabaseService._();

  // Getter per l'istanza
  static SupabaseService get instance => _instance;

  // Metodo di inizializzazione
  static Future<void> initialize() async {
    // Caricamento file env
    await dotenv.load(fileName: ".env");

    // Inizializzazione Supabase
    await Supabase.initialize(
      url: dotenv.env['PROJECT_URL'] ?? '',
      anonKey: dotenv.env['API_KEY'] ?? '',
      postgrestOptions: const PostgrestClientOptions(schema: 'cityclean'),
    );
  }
}

// Helper globale per accedere al client più facilmente in tutta l'app
final supabase = Supabase.instance.client;
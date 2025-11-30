import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- 1. IMPORTA PER LE DATE
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'components/auth_gate.dart'; // Assumendo che questo sia il punto di ingresso

// Variabile globale per accedere al client Supabase in modo semplice
final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carica le variabili d'ambiente dal file .env
  await dotenv.load(fileName: ".env");

  // Inizializza Supabase con le credenziali dal file .env
  await Supabase.initialize(
    url: dotenv.env['PROJECT_URL'] ?? '',
    anonKey: dotenv.env['API_KEY'] ?? '',
    // Specifica lo schema se necessario, come da configurazioni precedenti
    postgrestOptions: const PostgrestClientOptions(schema: 'cityclean'),
  );

  // --- 2. INIZIALIZZA LA LOCALIZZAZIONE (LA CORREZIONE CRITICA) ---
  // Questa riga è fondamentale per evitare il crash nella schermata eventi.
  await initializeDateFormatting('it_IT', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CityClean',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        fontFamily: 'Poppins', // Assicurati che il font sia definito in pubspec.yaml
      ),
      // Usa AuthGate come schermata principale come da configurazione precedente
      home: const AuthGate(),
    );
  }
}

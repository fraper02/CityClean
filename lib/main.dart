import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- IMPORT NECESSARIO
import 'components/auth_gate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//Questa variabile dovrebbe essere utilizzabile su tutta l'app
final supabase = Supabase.instance.client;

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  //Caricamento file env
  await dotenv.load(fileName: ".env");

  //.env variables
  await Supabase.initialize(
    url: dotenv.env['PROJECT_URL'] ?? '',
    anonKey: dotenv.env['API_KEY'] ?? '',
    postgrestOptions: const PostgrestClientOptions(schema: 'cityclean'),
  );

  // --- INIZIALIZZA LA LOCALIZZAZIONE ITALIANA PER LE DATE ---
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
      ),
      home: const AuthGate(),
    );
  }
}

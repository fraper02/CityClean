import 'package:cityclean/screens/splash_screen.dart';
import 'package:cityclean/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'components/auth_gate.dart';

// Ripristiniamo la variabile globale per compatibilità con il resto del progetto
late final SupabaseClient supabase;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

  // Assegniamo l'istanza del client alla variabile globale
  supabase = Supabase.instance.client;

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
        fontFamily: 'Poppins',
      ),
      home: const AuthGate(),
    );
  }
}

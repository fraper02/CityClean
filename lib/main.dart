import 'package:cityclean/screens/splash_screen.dart';
import 'package:cityclean/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'components/auth_gate.dart';


late final SupabaseClient supabase;


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    await SupabaseService.initialize();
    supabase = Supabase.instance.client;
    await initializeDateFormatting('it_IT', null);
  }

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
      // Il FutureBuilder gestisce gli stati di caricamento ed errore
      home: FutureBuilder(
        future: _initializationFuture,
        builder: (context, snapshot) {
          // Mentre l'app si sta inizializzando, mostra la SplashScreen
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }

          // Se si verifica un errore, mostra una schermata di errore sicura
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Errore di inizializzazione. Controlla la tua connessione e riavvia l'app.\nDettagli: ${snapshot.error}",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          // Se tutto è andato a buon fine, mostra l'AuthGate
          return const AuthGate();
        },
      ),
    );
  }
}

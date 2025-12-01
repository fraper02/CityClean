import 'package:cityclean/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:cityclean/services/supabase_service.dart';
import 'package:cityclean/components/auth_gate.dart';
import 'package:intl/date_symbol_data_local.dart'; // 1. Importa la libreria

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
    // 2. Avvia entrambe le inizializzazioni
    _initializationFuture = _initializeApp();
  }

  // 3. Crea un metodo per raggruppare le inizializzazioni
  Future<void> _initializeApp() async {
    // Eseguiamo le inizializzazioni in parallelo per massima efficienza
    await Future.wait([
      SupabaseService.initialize(),
      initializeDateFormatting('it_IT', null),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CityClean',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text("Errore di inizializzazione: ${snapshot.error}"),
              ),
            );
          }

          return const AuthGate();
        },
      ),
    );
  }
}

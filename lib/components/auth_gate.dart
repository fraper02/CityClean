import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../main.dart'; // Per accedere alla variabile 'supabase'

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      // Ascolta ogni cambiamento di stato (Login, Logout, Token scaduto, ecc.)
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // 1. Se sta ancora caricando (appena aperta l'app)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Recuperiamo la sessione corrente
        final session = snapshot.hasData ? snapshot.data!.session : null;

        // 3. Logica di reindirizzamento
        if (session != null) {
          // UTENTE LOGGATO -> Vai all'App (Profilo)
          return const ProfileScreen();
        } else {
          // UTENTE NON LOGGATO -> Vai al Login
          return const LoginScreen();
        }
      },
    );
  }
}
import 'package:cityclean/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cityclean/main.dart'; // Ripristinato import per la variabile globale
import '../screens/login_screen.dart';
import '../screens/admin/admin_dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange, // Usa di nuovo la variabile globale
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return FutureBuilder<bool>(
            future: _checkIfAdmin(session.user.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

              final isAdmin = snapshot.data ?? false;

              if (isAdmin) {
                return const AdminDashboard();
              }

              return const HomeScreen();
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }

  Future<bool> _checkIfAdmin(String userId) async {
    try {
      final data = await supabase
          .from('utente')
          .select('isadmin')
          .eq('idutente', userId)
          .single();
      return data['isadmin'] as bool? ?? false;
    } catch (e) {
      return false;
    }
  }
}

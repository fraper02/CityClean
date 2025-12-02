import 'package:cityclean/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cityclean/services/supabase_service.dart';
import '../screens/login_screen.dart';
import '../screens/admin/admin_dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          // L'utente è loggato. Controlliamo se è ADMIN.
          // Usiamo un FutureBuilder perché dobbiamo interrogare il DB
          return FutureBuilder<bool>(
            future: _checkIfAdmin(session.user.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

              final isAdmin = snapshot.data ?? false;

              // SE È ADMIN -> Dashboard Web
              if (isAdmin) {
                return const AdminDashboard();
              }

              // ALTRIMENTI -> App Utente Normale
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
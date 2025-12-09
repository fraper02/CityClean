import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notifiche.dart';
import '../services/storage_service.dart';
import '../main.dart'; // Per la variabile globale supabase
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  late AnimationController _fingerprintController;
  late Animation<double> _fingerprintAnimation;
  late AnimationController _buttonController;
  late Animation<double> _buttonWidthAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fingerprintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _fingerprintAnimation = Tween<double>(begin: 0.7, end: 1.2).animate(
      CurvedAnimation(parent: _fingerprintController, curve: Curves.easeInOut),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonWidthAnimation = Tween<double>(begin: 1.0, end: 55 / 350)
        .animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fingerprintController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    await _buttonController.forward();

    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = res.user;
      final Session? session = res.session;

      if (user != null && session != null) {
        await StorageService.saveSession(
            session.accessToken,
            session.refreshToken ?? '',
            user.id
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translateSupabaseError(error.message)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Errore imprevisto durante il login"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _buttonController.reverse();
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    // 1. Genera codice casuale
    final codiceGenerato = (100000 + (Random().nextInt(900000))).toString();

    // 2. Salvalo nel server o supabase
    await supabase.from('password_reset').insert({
      'email': email,
      'codice': codiceGenerato,
      'scadenza': DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
    });

    // 3. Invia notifica
    await NotificheService.notificaCodicePassword(
      codice: codiceGenerato,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Codice inviato alla tua email!")),
    );
  }


  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[600]!;
    final Gradient bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.green[700]!, Colors.green[400]!],
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 90,
                    width: 90,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                const Text("CityClean",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const Text("La tua app per l'ambiente",
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 50),

                const Align(alignment: Alignment.centerLeft, child: Text("Email", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),

                // --- MODIFICA MAESTRO: ID EMAIL ---
                Semantics(
                  identifier: 'email_input',
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                      hintText: "tuo@email.com",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Align(alignment: Alignment.centerLeft, child: Text("Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),

                // --- MODIFICA MAESTRO: ID PASSWORD ---
                Semantics(
                  identifier: 'password_input',
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      hintText: "........",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    child: const Text("Password dimenticata?", style: TextStyle(color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 20),

                AnimatedBuilder(
                  animation: _buttonController,
                  builder: (context, child) {
                    return SizedBox(
                      width: _isLoading
                          ? 55
                          : MediaQuery.of(context).size.width * _buttonWidthAnimation.value,
                      height: 55,
                      child: _isLoading
                          ? ScaleTransition(
                        scale: _fingerprintAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.fingerprint, color: Colors.green, size: 30),
                          ),
                        ),
                      )
                      // --- MODIFICA MAESTRO: ID BOTTONE ACCEDI ---
                          : Semantics(
                        identifier: 'login_button',
                        button: true, // Indica che è un pulsante
                        child: ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                          ),
                          child: const Text("Accedi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Non hai un account? ", style: TextStyle(color: Colors.white)),

                    // --- MODIFICA MAESTRO: ID REGISTRATI ---
                    Semantics(
                      identifier: 'register_text',
                      link: true, // Indica che funziona come un link
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          "Registrati",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String translateSupabaseError(String? message) {
  if (message == null || message.isEmpty) {
    return "Si è verificato un errore di autenticazione.";
  }

  final lower = message.toLowerCase();

  if (lower.contains("missing email") || lower.contains("missing phone")) {
    return "Inserisci la tua email.";
  }

  if (lower.contains("invalid login credentials") || lower.contains("password")) {
    return "Email o password non corretti.";
  }

  if (lower.contains("email not confirmed")) {
    return "Devi confermare la tua email prima di accedere.";
  }

  if (lower.contains("user not found")) {
    return "Nessun account trovato con questa email.";
  }

  return "Errore: $message";
}
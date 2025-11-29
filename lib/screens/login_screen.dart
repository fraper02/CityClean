import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // Per usare 'supabase'
import '../services/storage_service.dart'; // Per salvare l'ID
import 'register_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Funzione di Login Reale
  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Chiamata a Supabase
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = res.user;
      final Session? session = res.session;

      if (user != null && session != null) {
        // 2. Salva i dati sensibili nello Storage Sicuro (Opzionale ma richiesto da te)
        await StorageService.saveSession(
            session.accessToken,
            session.refreshToken ?? '',
            user.id
        );

        // NON serve Navigator.pushReplacement qui!
        // AuthGate rileverà il cambio di stato e mostrerà la Home.
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
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
      }
    }
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
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                    hintText: "tuo@email.com",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),

                const Align(alignment: Alignment.centerLeft, child: Text("Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: const Icon(Icons.visibility_outlined, color: Colors.grey),
                    hintText: "........",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Password dimenticata?", style: TextStyle(color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn, // Chiama la funzione _signIn
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.green)
                        : const Text("Accedi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                // ... (Resto del codice UI Registrati) ...
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Non hai un account? ", style: TextStyle(color: Colors.white)),
                    GestureDetector(
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
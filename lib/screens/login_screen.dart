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
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  bool _isLoading = false;
  bool _loginError = false;
  bool _showResultIcon = false;

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
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fingerprintController.dispose();
    _buttonController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _loginError = false;
      _showResultIcon = false;
    });

    await _buttonController.forward();

    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (res.user != null && res.session != null) {
        setState(() {
          _isLoading = false;
          _loginError = false;
          _showResultIcon = true;
        });

        await Future.delayed(const Duration(milliseconds: 800));
        return;
      }
    } on AuthException catch (_) {
      setState(() {
        _loginError = true;
        _showResultIcon = true;
        _isLoading = false;
      });
      _shakeController.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        setState(() {
          _showResultIcon = false;
          _loginError = false;
        });
        _buttonController.reverse();
      }
      return;
    } catch (_) {
      setState(() {
        _loginError = true;
        _showResultIcon = true;
        _isLoading = false;
      });
      _shakeController.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        setState(() {
          _showResultIcon = false;
          _loginError = false;
        });
        _buttonController.reverse();
      }
      return;
    }

    if (mounted) {
      setState(() {
        _showResultIcon = false;
      });
      _buttonController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: Listenable.merge([_buttonController, _shakeController]),
                  builder: (context, child) {
                    final bool isCircle = _isLoading || _showResultIcon;
                    return Transform.translate(
                      offset: Offset(
                        _shakeController.isAnimating ? _shakeAnimation.value : 0,
                        0,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isCircle
                            ? 55
                            : MediaQuery.of(context).size.width * _buttonWidthAnimation.value,
                        height: 55,
                        child: isCircle
                            ? Container(
                          decoration: BoxDecoration(
                            color: _loginError ? Colors.red : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: _showResultIcon
                                ? Icon(
                              _loginError ? Icons.close : Icons.check,
                              color: Colors.white,
                              size: 30,
                            )
                                : const CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.green,
                            ),
                          ),
                        )
                            : ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                          ),
                          child: const Text("Accedi",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                            decorationColor: Colors.white),
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
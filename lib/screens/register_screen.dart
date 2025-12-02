import 'package:cityclean/main.dart';
import 'package:cityclean/components/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller per i campi di testo
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _birthDateController = TextEditingController();

  bool _isPrivacyAccepted = false;
  bool _isLoading = false;

  // Funzione per mostrare il date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // Formatta la data in YYYY-MM-DD per il database
        _birthDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  // Funzione di registrazione
  Future<void> _handleRegister() async {
    if (!_isPrivacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Devi accettare la Privacy Policy per continuare.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Chiama Supabase Auth per creare l'utente
      // Passiamo i dati extra nel parametro `data` che verrà usato dal trigger
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'nome': _nameController.text.trim(),
          'cognome': _surnameController.text.trim(),
          'data_nascita': _birthDateController.text.trim(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrazione avvenuta! Controlla la tua email per confermare l account.')),
        );
        // Naviga all'AuthGate, che gestirà il reindirizzamento
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text('Si è verificato un errore inatteso: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Column(
              children: [
                const Text(
                  'Registrati',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text(
                  'Unisciti a CityClean oggi',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(child: _buildTextField(_nameController, Icons.person_outline, "Nome")),
                    const SizedBox(width: 15),
                    Expanded(child: _buildTextField(_surnameController, Icons.person_outline, "Cognome")),
                  ],
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: _buildTextField(_birthDateController, Icons.calendar_today, "Data di Nascita"),
                  ),
                ),
                const SizedBox(height: 15),
                _buildTextField(_emailController, Icons.email_outlined, "tuo@email.com"),
                const SizedBox(height: 15),
                _buildTextField(_passwordController, Icons.lock_outline, "Password", isPassword: true),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Checkbox(
                      value: _isPrivacyAccepted,
                      activeColor: Colors.white,
                      checkColor: primaryGreen,
                      side: const BorderSide(color: Colors.white, width: 2),
                      onChanged: (value) {
                        setState(() {
                          _isPrivacyAccepted = value ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Accetto la Privacy Policy',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister, // Usa la nuova funzione
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Registrati', // Testo del bottone cambiato
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Hai già un account? Accedi',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String hint, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

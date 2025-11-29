import 'package:flutter/material.dart';
import 'register_preferences_screen.dart'; // Importa la seconda schermata

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller per i campi di testo
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  bool _isPrivacyAccepted = false;
  bool _isEnglish = false; // Stato per la lingua

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
        _birthDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
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

    // Testi localizzati (simulati)
    final Map<String, String> texts = _isEnglish
        ? {
      'title': 'Register',
      'subtitle': 'Join CityClean today',
      'email': 'Email',
      'username': 'Username',
      'password': 'Password',
      'birthDate': 'Date of Birth',
      'privacy': 'I accept the Privacy Policy',
      'next': 'Next',
      'login': 'Already have an account? Login',
    }
        : {
      'title': 'Registrati',
      'subtitle': 'Unisciti a CityClean oggi',
      'email': 'Email',
      'username': 'Username',
      'password': 'Password',
      'birthDate': 'Data di Nascita',
      'privacy': 'Accetto la Privacy Policy',
      'next': 'Avanti',
      'login': 'Hai già un account? Accedi',
    };

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                // BARRA SUPERIORE CON LINGUA
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _isEnglish = !_isEnglish;
                        });
                      },
                      icon: const Icon(Icons.language, color: Colors.white),
                      label: Text(
                        _isEnglish ? "IT" : "EN", // Mostra la lingua a cui cambiare
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // TITOLO
                Text(
                  texts['title']!,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  texts['subtitle']!,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 40),

                // CAMPI DI INPUT
                _buildLabel(texts['email']!),
                _buildTextField(_emailController, Icons.email_outlined, "tuo@email.com"),
                const SizedBox(height: 15),

                _buildLabel(texts['username']!),
                _buildTextField(_usernameController, Icons.person_outline, "MarioRossi"),
                const SizedBox(height: 15),

                _buildLabel(texts['password']!),
                _buildTextField(_passwordController, Icons.lock_outline, "........", isPassword: true),
                const SizedBox(height: 15),

                _buildLabel(texts['birthDate']!),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: _buildTextField(_birthDateController, Icons.calendar_today, "GG/MM/AAAA"),
                  ),
                ),

                const SizedBox(height: 20),

                // CHECKBOX PRIVACY
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
                    Expanded(
                      child: Text(
                        texts['privacy']!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // BOTTONE AVANTI
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isPrivacyAccepted
                        ? () {
                      // Passiamo alla schermata successiva
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPreferencesScreen(
                            isEnglish: _isEnglish, // Passiamo la lingua scelta
                            // Qui potresti passare anche i dati raccolti (email, username, ecc.)
                          ),
                        ),
                      );
                    }
                        : null, // Disabilita se privacy non accettata
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                    child: Text(
                      texts['next']!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // LOGIN LINK
                TextButton(
                  onPressed: () => Navigator.pop(context), // Torna indietro (Login)
                  child: Text(
                    texts['login']!,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: Colors.white),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper per le etichette
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Helper per i campi di testo
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
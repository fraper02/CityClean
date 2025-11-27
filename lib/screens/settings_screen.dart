import 'package:flutter/material.dart';
import 'login_screen.dart'; // Per il logout

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Stato per lo switch delle notifiche
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // HEADER VERDE (Sfondo fisso)
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Intestazione con tasto Indietro
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Impostazioni",
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              "Gestisci le tue preferenze",
                              style: TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // CORREZIONE: Aumentato lo spazio per spingere il contenuto sotto l'header verde
                  const SizedBox(height: 80),

                  // SEZIONE PREFERENZE
                  const Text("Preferenze", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        // Switch Notifiche
                        SwitchListTile(
                          activeColor: primaryGreen,
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                            child: Icon(Icons.notifications_outlined, color: primaryGreen),
                          ),
                          title: const Text("Notifiche", style: TextStyle(fontWeight: FontWeight.w500)),
                          value: _notificationsEnabled,
                          onChanged: (bool value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          },
                        ),
                        const Divider(height: 1, indent: 60, endIndent: 20),
                        // Lingua
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                            child: Icon(Icons.language, color: primaryGreen),
                          ),
                          title: const Text("Lingua", style: TextStyle(fontWeight: FontWeight.w500)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text("Italiano", style: TextStyle(color: Colors.grey)),
                              Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                          onTap: () {
                            // Qui si aprirebbe il dialog per scegliere Inglese/Italiano
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // SEZIONE ACCOUNT
                  const Text("Account", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        _buildListTile(Icons.lock_outline, "Privacy e Sicurezza", primaryGreen),
                        const Divider(height: 1, indent: 60, endIndent: 20),
                        _buildListTile(Icons.help_outline, "Aiuto e Supporto", primaryGreen),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // BOTTONE ESCI
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // LOGOUT: Pulisce la storia di navigazione e va al Login
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryGreen,
                        side: BorderSide(color: primaryGreen, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text("Esci", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}
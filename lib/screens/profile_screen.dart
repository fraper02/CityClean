import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import 'rewards_screen.dart';
import 'settings_screen.dart'; // <--- IMPORTA IMPOSTAZIONI

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;
    final Color lightGreen = Colors.green[100]!;


    Future<int> getPoints() async {
      // Simula un ritardo di rete
      await Future.delayed(const Duration(seconds: 1));

      // Restituisce un valore fittizio (mock)
      // In un'app reale, qui faresti una chiamata HTTP:
      // final response = await http.get(Uri.parse('https://api.tuosito.com/user/points'));
      // return jsonDecode(response.body)['points'];
      return 350;
    }


    return Scaffold(
      backgroundColor: Colors.grey[100],

      // NAVBAR INFERIORE PERSONALIZZATA
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 2),

      body: Stack(
        children: [
          // SFONDO VERDE (HEADER)
          Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          // CONTENUTO SCORREVOLE
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Intestazione
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Profilo",
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Le tue informazioni",
                              style: TextStyle(fontSize: 16, color: Colors.white70),
                            ),
                          ],
                        ),
                        // BOTTONE IMPOSTAZIONI ATTIVO
                        IconButton(
                          onPressed: () {
                            // Apre la schermata impostazioni
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          },
                          icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                          tooltip: "Impostazioni",
                        ),
                      ],
                    ),
                  ),

                  // (Il resto del codice rimane identico al precedente, lo includo per completezza)
                  const SizedBox(height: 10),

                  // CARD BIANCA PRINCIPALE
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: lightGreen,
                          child: Icon(Icons.person_outline, size: 50, color: primaryGreen),
                        ),
                        const SizedBox(height: 15),
                        const Text("Mario Rossi", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const Text("Membro dal 2024", style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Expanded(child: _buildStatBox(icon: Icons.calendar_today, value: "24", label: "Ordini", color: primaryGreen)),
                            const SizedBox(width: 15),
                            Expanded(child: _buildStatBox(icon: Icons.workspace_premium, value: "350", label: "Punti", color: primaryGreen)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // LISTA INFORMAZIONI
                  _buildInfoCard(Icons.email_outlined, "Email", "mario.rossi@email.com", primaryGreen),
                  _buildInfoCard(Icons.phone_outlined, "Telefono", "+39 123 456 7890", primaryGreen),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET HELPER (Identici a prima)
  Widget _buildStatBox({required IconData icon, required String value, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color iconColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
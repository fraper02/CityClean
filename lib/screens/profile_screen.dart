// C:/Users/antop/StudioProjects/CityClean/lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import 'redeemed_rewards_screen.dart'; // <-- IMPORT NUOVA PAGINA
import 'settings_screen.dart';

// Funzione di mocking per i dati del profilo
Future<Map<String, dynamic>> getMockProfileData() async {
  await Future.delayed(const Duration(milliseconds: 800));
  return {
    "name": "Mario Rossi",
    "memberSince": "2024",
    "orders": 24,
    "points": 350,
    "email": "mario.rossi@email.com",
    "phone": "+39 123 456 7890",
  };
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = getMockProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 2),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mostra una UI "scheletro" durante il caricamento
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Impossibile caricare il profilo."));
          }

          // Dati mock recuperati
          final profileData = snapshot.data!;
          final primaryGreen = Colors.green[700]!;

          // Costruisci la UI con i dati
          return _buildProfileUI(context, profileData, primaryGreen);
        },
      ),
    );
  }

  // Metodo per costruire la UI una volta che i dati sono disponibili
  Widget _buildProfileUI(BuildContext context, Map<String, dynamic> data, Color primaryGreen) {
    return Stack(
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
                // Intestazione con nome dinamico
                _buildHeader(context, "Profilo", "Le tue informazioni"),

                const SizedBox(height: 10),

                // CARD BIANCA PRINCIPALE con dati dinamici
                _buildMainProfileCard(context, data, primaryGreen),

                const SizedBox(height: 20),

                // ---- NUOVA SEZIONE: CARD DI NAVIGAZIONE ----
                _buildNavigationCard(
                  context: context,
                  icon: Icons.card_giftcard_outlined,
                  label: "Premi Riscattati",
                  subtitle: "Visualizza la cronologia dei tuoi premi",
                  iconColor: primaryGreen,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RedeemedRewardsScreen()),
                    );
                  },
                ),
                // ------------------------------------------

                // LISTA INFORMAZIONI con dati dinamici
                _buildInfoCard(Icons.email_outlined, "Email", data['email'], primaryGreen),
                _buildInfoCard(Icons.phone_outlined, "Telefono", data['phone'], primaryGreen),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET HELPER PER LEGGIBILITÀ ---

  Widget _buildHeader(BuildContext context, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 5),
              Text(subtitle, style: const TextStyle(fontSize: 16, color: Colors.white70)),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
            tooltip: "Impostazioni",
          ),
        ],
      ),
    );
  }

  Widget _buildMainProfileCard(BuildContext context, Map<String, dynamic> data, Color primaryGreen) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.green[100],
            child: Icon(Icons.person_outline, size: 50, color: primaryGreen),
          ),
          const SizedBox(height: 15),
          Text(data['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("Membro dal ${data['memberSince']}", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(child: _buildStatBox(icon: Icons.calendar_today, value: data['orders'].toString(), label: "Ordini", color: primaryGreen)),
              const SizedBox(width: 15),
              Expanded(child: _buildStatBox(icon: Icons.workspace_premium, value: data['points'].toString(), label: "Punti", color: primaryGreen)),
            ],
          ),
        ],
      ),
    );
  }

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

  // --- WIDGET HELPER PER LA NUOVA CARD DI NAVIGAZIONE ---
  Widget _buildNavigationCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
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

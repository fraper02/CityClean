import 'package:cityclean/screens/badge_screen.dart';
import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import 'redeemed_rewards_screen.dart';
import 'guilds_list_screen.dart';
import '../models/userProfile.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  late Future<UserProfile> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _userService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 2),
      body: FutureBuilder<UserProfile>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Impossibile caricare il profilo."));
          }

          final userProfile = snapshot.data!;
          final primaryGreen = Colors.green[700]!;

          return _buildProfileUI(context, userProfile, primaryGreen);
        },
      ),
    );
  }

  Widget _buildProfileUI(BuildContext context, UserProfile user, Color primaryGreen) {
    return Stack(
      children: [
        Container(
          height: 200,
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
            child: Column(
              children: [
                _buildHeader(context, "Profilo", "Le tue informazioni"),
                const SizedBox(height: 10),
                Container(
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
                        backgroundImage: user.fotoProfilo != null ? NetworkImage(user.fotoProfilo!) : null,
                        child: user.fotoProfilo == null
                            ? Icon(Icons.person_outline, size: 50, color: primaryGreen)
                            : null,
                      ),
                      const SizedBox(height: 15),
                      Text("${user.nome} ${user.cognome ?? ''}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const Text("Membro CityClean", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(child: _buildStatBox(icon: Icons.qr_code, value: user.codiceReferral, label: "Tuo Codice", color: primaryGreen)),
                          const SizedBox(width: 15),
                          Expanded(child: _buildStatBox(icon: Icons.workspace_premium, value: user.saldoPunti.toString(), label: "Punti", color: primaryGreen)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // CARD PREMI RISCATTATI
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

                // --- CARD BADGE (NUOVA) ---
                _buildNavigationCard(
                  context: context,
                  icon: Icons.shield_outlined, // Icona diversa
                  label: "I Tuoi Badge",
                  subtitle: "Scopri i badge che hai sbloccato",
                  iconColor: primaryGreen,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BadgeScreen()),
                    );
                  },
                ),

                // CARD GILDA
                _buildNavigationCard(
                    context: context,
                    icon: Icons.group_work_outlined,
                    label: "Gilda",
                    subtitle: "Cerca o crea una gilda",
                    iconColor: primaryGreen,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GuildsListScreen()),
                      );
                    }),

                // INFO EMAIL
                _buildInfoCard(Icons.email_outlined, "Email", user.email, primaryGreen),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

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
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNavigationCard({required BuildContext context, required IconData icon, required String label, required String subtitle, required Color iconColor, required VoidCallback onTap}) {
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

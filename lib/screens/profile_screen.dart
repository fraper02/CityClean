import 'package:cityclean/controllers/profile_controller.dart';
import 'package:cityclean/models/user_profile.dart';
import 'package:cityclean/screens/objectives_screen.dart';
import 'package:cityclean/services/report_service.dart';
import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import 'collection_history_screen.dart';
import 'home_screen.dart';
import 'redeemed_rewards_screen.dart';
import 'guilds_list_screen.dart';
import 'badge_screen.dart';
import 'user_activity_screen.dart';
//import Geolocator
//import LatLong
//import DateFormat
//import Location Picker

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;
  final ReportService _reportService = ReportService();

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
    _controller.loadUserProfile();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 2),
      body: ValueListenableBuilder<ProfileScreenState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          if (state == ProfileScreenState.loading || state == ProfileScreenState.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state == ProfileScreenState.error) {
            return Center(child: Text(_controller.errorMessage.value));
          }

          return ValueListenableBuilder<UserProfile?>(
            valueListenable: _controller.userProfile,
            builder: (context, userProfile, _ ){
              if (userProfile == null) {
                return const Center(child: Text("Profilo non disponibile."));
              }
              return _buildProfileUI(context, userProfile, Colors.green[700]!);
            }
          );
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
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () => _controller.showTitleSelection(context, primaryGreen),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.titolo ?? 'Nessun titolo', // Modificato per chiarezza
                              style: const TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.edit, color: Colors.grey, size: 16),
                          ],
                        ),
                      ),
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

                // --- NUOVO PULSANTE CRONOLOGIA ATTIVITÀ ---
                _buildNavigationCard(
                  context: context,
                  icon: Icons.history,
                  label: "Cronologia Attività",
                  subtitle: "Visualizza tutte le tue attività recenti",
                  iconColor: primaryGreen,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserActivityScreen()),
                    );
                  },
                ),
                _buildNavigationCard(
                  context: context,
                  icon: Icons.history,
                  label: "Storico Raccolte",
                  subtitle: "Visualizza lo storico delle tue raccolte",
                  iconColor: primaryGreen,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CollectionHistoryScreen()),
                    );
                  },
                ),
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
                _buildNavigationCard(
                  context: context,
                  icon: Icons.shield_outlined,
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
                _buildNavigationCard(
                  context: context,
                  icon: Icons.flag_outlined,
                  label: "I Miei Obiettivi",
                  subtitle: "Guarda i tuoi progressi e obiettivi",
                  iconColor: primaryGreen,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ObjectivesScreen()),
                    );
                  },
                ),
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
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
              ),
              const SizedBox(width: 10),
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

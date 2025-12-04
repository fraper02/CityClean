import 'package:cityclean/models/userProfile.dart';
import 'package:cityclean/services/user_service.dart';
import 'package:cityclean/screens/profile_screen.dart';
import 'package:cityclean/screens/settings_screen.dart';
import 'package:cityclean/screens/guilds_list_screen.dart';
import 'package:cityclean/screens/redeemed_rewards_screen.dart';
import 'package:cityclean/screens/subscribed_events_screen.dart';
import 'package:cityclean/screens/qr_scanner_screen.dart';
import 'package:cityclean/screens/badge_screen.dart';
import 'package:cityclean/components/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      body: FutureBuilder<UserProfile>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Errore nel caricamento dei dati"));
          }

          final userProfile = snapshot.data!;

          return SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: 200, 
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        _buildHeader(context, userProfile),
                        // Ridotto lo spazio per portare la card più in alto
                        const SizedBox(height: 20),
                        
                        _buildProfileCard(context, userProfile),
                        const SizedBox(height: 20),

                        _buildMainAction(context),
                        const SizedBox(height: 15),

                        _buildSubscribedEventsAction(context),
                        const SizedBox(height: 20),

                        _buildOptionsGrid(context),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ciao ${user.nome}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Text(
              "Benvenuto nella tua home",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, UserProfile user) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFE0F2F1),
              child: const Icon(Icons.person, size: 30, color: Colors.green),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text("Membro dal 2024", style: TextStyle(color: Colors.grey)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text("${user.saldoPunti}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800])),
                  Text("Punti", style: TextStyle(color: Colors.green[800])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 90,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QrScannerScreen()),
          );
        },
        icon: const Icon(Icons.qr_code_scanner, size: 30),
        label: const Text("Inizia a Riciclare", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildSubscribedEventsAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SubscribedEventsScreen()),
          );
        },
        icon: Icon(Icons.event_available_outlined, color: Colors.green[700]),
        label: Text(
          "I Miei Eventi",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.green[100],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          side: BorderSide(color: Colors.green[700]!, width: 2),
        ),
      ),
    );
  }

  Widget _buildOptionsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildOptionCard(Icons.group_work_outlined, "Cerca Gilda", onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const GuildsListScreen()));
        }),
        _buildOptionCard(Icons.card_giftcard_outlined, "Storico Premi", onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const RedeemedRewardsScreen()));
        }),
        _buildOptionCard(Icons.shield_outlined, "I Miei Badge", onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const BadgeScreen()));
        }),
      ],
    );
  }

  Widget _buildOptionCard(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green[700]),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

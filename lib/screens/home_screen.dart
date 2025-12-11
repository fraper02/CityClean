import 'package:cityclean/models/user_profile.dart';
import 'package:cityclean/services/recycling_service.dart';
import 'package:cityclean/services/user_service.dart';
import 'package:cityclean/screens/profile_screen.dart';
import 'package:cityclean/screens/settings_screen.dart';
import 'package:cityclean/screens/guilds_list_screen.dart';
import 'package:cityclean/screens/redeemed_rewards_screen.dart';
import 'package:cityclean/screens/subscribed_events_screen.dart';
import 'package:cityclean/screens/qr_scanner_screen.dart';
import 'package:cityclean/screens/badge_screen.dart';
import 'package:cityclean/screens/objectives_screen.dart';
import 'package:cityclean/screens/missions_screen.dart';
import 'package:cityclean/screens/collection_history_screen.dart';
import 'package:cityclean/components/bottom_nav_bar.dart';
import 'package:cityclean/screens/create_event_screen.dart';
import 'package:flutter/material.dart';
import 'group_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final UserService _userService = UserService();
  final RecyclingService _recyclingService = RecyclingService();
  Future<UserProfile>? _profileDataFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadProfile();
      // Refresh the UI to reflect the latest recycling state
      setState(() {});
    }
  }

  void _loadProfile() {
    setState(() {
      _profileDataFuture = _userService.getCurrentUser();
    });
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

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        _buildHeader(context, userProfile),
                        const SizedBox(height: 15),
                        _buildProfileCard(context, userProfile),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: [
                      _buildMainAction(context),
                      const SizedBox(height: 15),
                      _buildSubscribedEventsAction(context),
                      const SizedBox(height: 20),
                      _buildOptionsGrid(context, userProfile.id),
                    ],
                  ),
                ),
              ),
            ],
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
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        _loadProfile();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10
            )
          ],
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
                Text(user.titolo ?? 'Membro CityClean', style: const TextStyle(color: Colors.grey)),
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
    return FutureBuilder<bool>(
      // Use a key to re-trigger the future when the state changes
      key: ValueKey(DateTime.now()),
      future: _recyclingService.isRecycling(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: double.infinity,
            height: 90,
            child: ElevatedButton.icon(
              onPressed: null, // Disabled while loading
              icon: const Icon(Icons.hourglass_empty, size: 30),
              label: const Text("Caricamento...", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          );
        }

        final isRecycling = snapshot.data ?? false;

        return SizedBox(
          width: double.infinity,
          height: 90,
          child: ElevatedButton.icon(
            onPressed: () async {
              if (isRecycling) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QrScannerScreen()),
                );
              } else {
                await _recyclingService.startRecycling();
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapScreen()),
                );
              }
              // Rebuild the widget to reflect the new state
              setState(() {});
            },
            icon: Icon(isRecycling ? Icons.stop_circle_outlined : Icons.qr_code_scanner, size: 30),
            label: Text(
              isRecycling ? "Concludi sessione" : "Inizia a Riciclare",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isRecycling ? Colors.red[600] : Colors.green[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        );
      },
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

  Widget _buildOptionsGrid(BuildContext context, String userId) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildOptionCard(Icons.shield_outlined, "I Miei Badge", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const BadgeScreen()));
            })),
            const SizedBox(width: 15),
            Expanded(child: _buildOptionCard(Icons.card_giftcard_outlined, "Storico Premi", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RedeemedRewardsScreen()));
            })),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildOptionCard(Icons.group_work_outlined, "Cerca Gilda", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const GuildsListScreen()));
            })),
            const SizedBox(width: 15),
            Expanded(child: _buildOptionCard(Icons.add_circle_outline, "Segnala Evento Futuro", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CreateEventScreen(userId: userId)));
            })),
          ],
        ),
        const SizedBox(height: 15),
        _buildFullWidthCard(Icons.flag_outlined, "I Miei Obiettivi", onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ObjectivesScreen()));
        }),
        const SizedBox(height: 15),
        _buildFullWidthCard(Icons.assignment_turned_in_outlined, "Missioni", onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MissionsScreen()));
        }),
        const SizedBox(height: 15),
        _buildFullWidthCard(Icons.group_outlined, "Gruppi", onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const GroupScreen()));
        }),
        const SizedBox(height: 15),
        _buildFullWidthCard(Icons.history, "Storico Raccolte", onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CollectionHistoryScreen()));
        }),
      ],
    );
  }

  Widget _buildOptionCard(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: Colors.green[700]),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidthCard(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: Colors.green[700]),
            const SizedBox(width: 15),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

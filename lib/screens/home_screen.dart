import 'package:cityclean/models/userProfile.dart';
// import 'package:cityclean/services/user_service.dart'; // Non serve più per il real-time
import 'package:cityclean/screens/profile_screen.dart';
import 'package:cityclean/screens/settings_screen.dart';
import 'package:cityclean/screens/guilds_list_screen.dart';
import 'package:cityclean/screens/redeemed_rewards_screen.dart';
import 'package:cityclean/screens/subscribed_events_screen.dart';
import 'package:cityclean/screens/qr_scanner_screen.dart';
import 'package:cityclean/screens/badge_screen.dart';
import 'package:cityclean/components/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import necessario per lo stream

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Usiamo uno Stream invece di un Future per ascoltare i cambiamenti in tempo reale
  late Stream<UserProfile> _profileStream;

  @override
  void initState() {
    super.initState();
    _setupProfileStream();
  }

  void _setupProfileStream() {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;

    if (userId != null) {
      // Creiamo uno stream che ascolta la tabella 'utente' per l'ID corrente
      _profileStream = client
          .from('utente')
          .stream(primaryKey: ['idutente']) // Serve per identificare le righe uniche
          .eq('idutente', userId)
          .map((data) {
        // Lo stream restituisce una lista di mappe (righe)
        if (data.isEmpty) {
          throw Exception("Profilo utente non trovato");
        }
        // Convertiamo la prima riga in un oggetto UserProfile
        return UserProfile.fromJson(data.first);
      });
    } else {
      // Fallback se non c'è utente (non dovrebbe accadere grazie all'AuthGate)
      _profileStream = const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // StreamBuilder ricostruisce la UI ogni volta che arrivano nuovi dati dal DB
      body: StreamBuilder<UserProfile>(
        stream: _profileStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text("Errore nel caricamento dei dati: ${snapshot.error}"));
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
              // Gestione immagine profilo se presente
              backgroundImage: user.fotoProfilo != null ? NetworkImage(user.fotoProfilo!) : null,
              child: user.fotoProfilo == null ? const Icon(Icons.person, size: 30, color: Colors.green) : null,
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text("Membro CityClean", style: TextStyle(color: Colors.grey)),
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
                  // Questo testo si aggiornerà automaticamente!
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
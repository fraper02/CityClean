// C:/Users/antop/StudioProjects/CityClean/lib/screens/rewards_screen.dart

import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import 'dart:async'; // Import necessario per Future e Stream

// --- 1. MODELLO DATI INTEGRATO ---
// Il modello per i premi è ora definito direttamente in questo file.
class Reward {
  final String title;
  final int points;
  final String iconName;

  const Reward({
    required this.title,
    required this.points,
    required this.iconName,
  });
}

// --- 2. FUNZIONI DI MOCKING INTEGRATE ---
// Funzioni che simulano chiamate di rete, ora definite localmente.

/// Funzione mock per recuperare il saldo punti dell'utente.
Future<int> getMockPoints() async {
  await Future.delayed(const Duration(seconds: 1));
  return 350;
}

/// Funzione mock per recuperare la lista dei premi disponibili.
Future<List<Reward>> getMockAvailableRewards() async {
  await Future.delayed(const Duration(milliseconds: 1500));
  return const [
    Reward(title: "Sconto 10%", points: 100, iconName: 'card_giftcard'),
    Reward(title: "Prodotto Omaggio", points: 250, iconName: 'star_outline'),
    Reward(title: "Premio Speciale", points: 500, iconName: 'emoji_events_outlined'),
    Reward(title: "Spedizione Gratuita", points: 150, iconName: 'local_shipping_outlined'),
    Reward(title: "Gadget Esclusivo", points: 400, iconName: 'redeem'),
  ];
}


// Mappa e funzione helper per convertire i nomi delle icone in IconData
const Map<String, IconData> _iconMap = {
  'card_giftcard': Icons.card_giftcard,
  'star_outline': Icons.star_outline,
  'emoji_events_outlined': Icons.emoji_events_outlined,
  'local_shipping_outlined': Icons.local_shipping_outlined,
  'redeem': Icons.redeem,
};

IconData getIconFromString(String iconName) {
  return _iconMap[iconName] ?? Icons.help_outline;
}


// --- SCHERMATA PRINCIPALE (StatefulWidget) ---
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  // Future che attenderà il completamento di entrambe le chiamate
  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    // Eseguiamo entrambe le chiamate (ora locali) in parallelo
    _dataFuture = Future.wait([
      getMockPoints(),          // <-- Chiama la funzione di mock locale
      getMockAvailableRewards(), // <-- Chiama la funzione di mock locale
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 1),
      // FutureBuilder per gestire il caricamento dei dati
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.length < 2) {
            return const Center(child: Text("Impossibile caricare i dati dei premi."));
          }

          // Estraiamo i dati dalla lista dei risultati
          final int userPoints = snapshot.data![0];
          final List<Reward> availableRewards = snapshot.data![1];

          // Una volta che abbiamo tutti i dati, costruiamo la UI
          return _buildContentUI(context, userPoints, availableRewards);
        },
      ),
    );
  }

  /// Metodo che costruisce l'intera UI quando tutti i dati sono stati caricati.
  Widget _buildContentUI(BuildContext context, int userPoints, List<Reward> availableRewards) {
    // Palette colori
    final Color primaryGreen = Colors.green[700]!;
    final Color lightGreenCard = Colors.lightGreen[100]!;
    final Color iconBgGreen = Colors.lightGreen[50]!;

    return Stack(
      children: [
        // Header
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            color: primaryGreen,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),

        // Contenuto scorrevole
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Testi Intestazione con punti dinamici
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Riscatto Premi", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 5),
                      Text("I tuoi punti: $userPoints", style: const TextStyle(fontSize: 16, color: Colors.white70)),
                    ],
                  ),
                ),

                // Card Riepilogo Punti
                _buildPointsSummaryCard(userPoints, lightGreenCard, primaryGreen),

                const SizedBox(height: 25),

                // Titolo Sezione "Premi disponibili"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Premi disponibili", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800])),
                ),
                const SizedBox(height: 15),

                // Lista premi dinamica
                ListView.builder(
                  itemCount: availableRewards.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final reward = availableRewards[index];
                    return _buildRewardCard(
                      reward: reward,
                      iconBg: iconBgGreen,
                      iconColor: primaryGreen,
                      canRedeem: userPoints >= reward.points,
                      onRedeem: () => print("Tentativo di riscatto: ${reward.title}"),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET HELPER PER LEGGIBILITÀ ---

  Widget _buildPointsSummaryCard(int userPoints, Color cardColor, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Punti disponibili", style: TextStyle(color: Colors.green[800], fontSize: 14)),
              const SizedBox(height: 5),
              Text(userPoints.toString(), style: TextStyle(color: Colors.green[900], fontSize: 36, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
            child: const Icon(Icons.star, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard({
    required Reward reward,
    required Color iconBg,
    required Color iconColor,
    required bool canRedeem,
    required VoidCallback onRedeem,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(getIconFromString(reward.iconName), color: iconColor, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text("${reward.points} punti", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canRedeem ? onRedeem : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text("Riscatta"),
          ),
        ],
      ),
    );
  }
}

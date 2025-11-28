// lib/screens/redeemed_rewards_screen.dart

import 'package:flutter/material.dart';

// Modello dati per un premio riscattato (potrebbe includere la data)
class RedeemedReward {
  final String title;
  final int points;
  final DateTime date;

  const RedeemedReward({
    required this.title,
    required this.points,
    required this.date,
  });
}

// Funzione di Mocking per recuperare i premi riscattati
Future<List<RedeemedReward>> getMockRedeemedRewards() async {
  await Future.delayed(const Duration(seconds: 1));
  return [
    RedeemedReward(title: "Sconto 10%", points: 100, date: DateTime(2025, 10, 28)),
    RedeemedReward(title: "Spedizione Gratuita", points: 150, date: DateTime(2025, 9, 15)),
    RedeemedReward(title: "Prodotto Omaggio", points: 250, date: DateTime(2025, 8, 5)),
  ];
}


class RedeemedRewardsScreen extends StatelessWidget {
  const RedeemedRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Premi Riscattati"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<RedeemedReward>>(
        future: getMockRedeemedRewards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nessun premio riscattato."));
          }

          final redeemedRewards = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: redeemedRewards.length,
            itemBuilder: (context, index) {
              final reward = redeemedRewards[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(Icons.check_circle_outline, color: Colors.green[600]),
                  title: Text(reward.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${reward.points} punti"),
                  // Formatta la data per una migliore leggibilità
                  trailing: Text(
                    "${reward.date.day}/${reward.date.month}/${reward.date.year}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// lib/screens/redeemed_rewards_screen.dart

import 'package:flutter/material.dart';
import '../controllers/redeemed_rewards_controller.dart'; // 1. Importa il Controller
import '../models/redeemed_reward.dart';

// La schermata diventa uno StatefulWidget per gestire il ciclo di vita del Controller
class RedeemedRewardsScreen extends StatefulWidget {
  const RedeemedRewardsScreen({super.key});

  @override
  State<RedeemedRewardsScreen> createState() => _RedeemedRewardsScreenState();
}

class _RedeemedRewardsScreenState extends State<RedeemedRewardsScreen> {
  // 2. Istanza del Controller
  late final RedeemedRewardsController _controller;

  @override
  void initState() {
    super.initState();
    // Crea l'istanza del controller e avvia il caricamento dei dati
    _controller = RedeemedRewardsController();
    _controller.fetchRedeemedRewards();
  }

  @override
  void dispose() {
    // Libera le risorse del controller quando la schermata viene distrutta
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Premi Riscattati"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],

      // 3. ValueListenableBuilder ascolta i cambiamenti di stato dal controller
      body: ValueListenableBuilder<ScreenState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          // In base allo stato, mostra il widget appropriato
          switch (state) {
            case ScreenState.loading:
            case ScreenState.initial:
              return const Center(child: CircularProgressIndicator());

            case ScreenState.error:
              return Center(
                // Ascolta anche il messaggio di errore specifico
                child: ValueListenableBuilder<String>(
                  valueListenable: _controller.errorMessage,
                  builder: (context, message, _) => Text("Errore: $message"),
                ),
              );

            case ScreenState.success:
            // Se lo stato è "success", costruisce la lista dei premi
            // ascoltando il notifier dei dati.
              return _buildRewardsList();
          }
        },
      ),
    );
  }

  // Widget helper per costruire la lista dei premi
  Widget _buildRewardsList() {
    return ValueListenableBuilder<List<RedeemedReward>>(
      valueListenable: _controller.rewards,
      builder: (context, rewards, _) {
        if (rewards.isEmpty) {
          return const Center(child: Text("Non hai ancora riscattato nessun premio."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: rewards.length,
          itemBuilder: (context, index) {
            final reward = rewards[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.check_circle_outline, color: Colors.green[600]),
                title: Text(reward.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${reward.points} punti"),
                trailing: Text(
                  "${reward.date.day.toString().padLeft(2, '0')}/${reward.date.month.toString().padLeft(2, '0')}/${reward.date.year}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

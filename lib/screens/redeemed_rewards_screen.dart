// lib/screens/redeemed_rewards_screen.dart

import 'package:flutter/material.dart';
import '../controllers/redeemed_rewards_controller.dart';
import '../models/redeemed_reward.dart';

class RedeemedRewardsScreen extends StatefulWidget {
  const RedeemedRewardsScreen({super.key});

  @override
  State<RedeemedRewardsScreen> createState() => _RedeemedRewardsScreenState();
}

class _RedeemedRewardsScreenState extends State<RedeemedRewardsScreen> {
  late final RedeemedRewardsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RedeemedRewardsController();
    _controller.fetchRedeemedRewards();
  }

  @override
  void dispose() {
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
      body: ValueListenableBuilder<ScreenState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          switch (state) {
            case ScreenState.loading:
            case ScreenState.initial:
              return const Center(child: CircularProgressIndicator());

            case ScreenState.error:
              return Center(
                child: ValueListenableBuilder<String>(
                  valueListenable: _controller.errorMessage,
                  builder: (context, message, _) =>
                      Text("Errore: $message"),
                ),
              );

            case ScreenState.success:
              return _buildRewardsList();
          }
        },
      ),
    );
  }

  // LISTA PREMI
  Widget _buildRewardsList() {
    return ValueListenableBuilder<List<RedeemedReward>>(
      valueListenable: _controller.rewards,
      builder: (context, rewards, _) {
        if (rewards.isEmpty) {
          return const Center(
              child: Text("Non hai ancora riscattato nessun premio."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: rewards.length,
          itemBuilder: (context, index) {
            final reward = rewards[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.check_circle_outline,
                    color: Colors.green[600]),
                title: Text(
                  reward.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${reward.points} punti"),
                trailing: Text(
                  "${reward.date.day.toString().padLeft(2, '0')}/"
                      "${reward.date.month.toString().padLeft(2, '0')}/"
                      "${reward.date.year}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),

                // 👇 AGGIUNTO: TAP → POPUP DETTAGLI
                onTap: () => _showRewardPopup(reward),
              ),
            );
          },
        );
      },
    );
  }

  // POPUP DETTAGLI PREMIO
  void _showRewardPopup(RedeemedReward reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          reward.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Punti spesi: ${reward.points}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              "Data riscatto: "
                  "${reward.date.day.toString().padLeft(2, '0')}/"
                  "${reward.date.month.toString().padLeft(2, '0')}/"
                  "${reward.date.year}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Chiudi"),
          ),
        ],
      ),
    );
  }
}

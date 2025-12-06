// lib/screens/rewards_screen.dart

import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import '../controllers/rewards_controller.dart';
import '../models/prizes.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  late final RewardsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RewardsController();
    _controller.loadScreenData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRedeemPrize(Prize prize) async {
    final int currentPoints = _controller.userPoints.value;

    if (prize.quantitaDisponibile <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Questo premio non è più disponibile.")),
      );
      return;
    }

    if (currentPoints < prize.costoPunti) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Punti insufficienti. Ti servono ${prize.costoPunti} punti.")),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Conferma riscatto"),
        content: Text("Vuoi riscattare '${prize.nome}' per ${prize.costoPunti} punti?"),
        actions: [
          // MAESTRO ID: Bottone Annulla
          Semantics(
            identifier: 'dialog_cancel_button',
            child: TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annulla"),
            ),
          ),
          // MAESTRO ID: Bottone Conferma
          Semantics(
            identifier: 'dialog_confirm_button',
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Conferma"),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _controller.redeemPrize(prize);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hai riscattato '${prize.nome}' con successo!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore nel riscatto: $e")),
        );
      }
    }
  }

  void _showPrizeDescription(Prize prize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(prize.nome),
        content: Text(prize.descrizione ?? "Nessuna descrizione disponibile."),
        actions: [
          // MAESTRO ID: Chiudi descrizione
          Semantics(
            identifier: 'dialog_close_description',
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Chiudi"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 1),
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
                  builder: (context, message, _) => Text("Errore: $message"),
                ),
              );
            case ScreenState.success:
              return _buildContentUI();
          }
        },
      ),
    );
  }

  Widget _buildContentUI() {
    final Color primaryGreen = Colors.green[700]!;
    final Color lightGreenCard = Colors.lightGreen[100]!;
    final Color iconBgGreen = Colors.lightGreen[50]!;

    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: primaryGreen,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Riscatto Premi",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<int>(
                valueListenable: _controller.userPoints,
                builder: (context, points, _) {
                  return _buildPointsSummaryCard(points, lightGreenCard, primaryGreen);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "Premi disponibili",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800]),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<List<Prize>>(
            valueListenable: _controller.availablePrizes,
            builder: (context, prizes, _) {
              if (prizes.isEmpty) {
                return const Center(child: Text("Al momento non ci sono premi disponibili."));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: prizes.length,
                itemBuilder: (context, index) {
                  final prize = prizes[index];
                  final bool canRedeem = _controller.userPoints.value >= prize.costoPunti && prize.quantitaDisponibile > 0;

                  return _buildPrizeCard(
                    prize: prize,
                    iconBg: iconBgGreen,
                    iconColor: primaryGreen,
                    canRedeem: canRedeem,
                    onRedeem: () => _handleRedeemPrize(prize),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPointsSummaryCard(int userPoints, Color cardColor, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Punti disponibili", style: TextStyle(color: Colors.green[800], fontSize: 14)),
              const SizedBox(height: 5),
              // MAESTRO ID
              Semantics(
                identifier: 'user_points_display',
                child: Text(
                  userPoints.toString(),
                  style: TextStyle(color: Colors.green[900], fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
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

  Widget _buildPrizeCard({
    required Prize prize,
    required Color iconBg,
    required Color iconColor,
    required bool canRedeem,
    required VoidCallback onRedeem,
  }) {
    final bool isAvailable = prize.quantitaDisponibile > 0;

    // Generazione nomi puliti
    final String cleanName = prize.nome.replaceAll(' ', '');

    // ID per il bottone verde
    final String buttonId = "${cleanName}BottoneRiscatta";

    // ID per l'intera card (l'item della lista)
    final String itemId = "${cleanName}Item";

    // 1. Semantics per l'intera card (per aprire i dettagli)
    return Semantics(
      identifier: itemId,
      child: InkWell(
        onTap: () => _showPrizeDescription(prize),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(Icons.redeem, color: iconColor, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prize.nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text("${prize.costoPunti} punti", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ),

              // 2. Semantics specifico per il bottone "Riscatta"
              Semantics(
                identifier: buttonId,
                container: true,
                child: ElevatedButton(
                  onPressed: canRedeem ? onRedeem : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Text(isAvailable ? "Riscatta" : "Terminato"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
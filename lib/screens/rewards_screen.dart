// C:/Users/Saverio/StudioProjects/CityClean/lib/screens/rewards_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:developer';

import '../components/bottom_nav_bar.dart';
import '../main.dart'; // Per accedere a `supabase`
import '../models/prizes.dart'; // Usa il tuo modello Prize aggiornato

// --- FUNZIONI DI ACCESSO AI DATI REALI ---

/// Carica i dati dell'utente e dei premi direttamente da Supabase.
Future<Map<String, dynamic>> _loadRealData() async {
  final user = supabase.auth.currentUser;
  if (user == null) {
    throw Exception("Utente non autenticato.");
  }

  // Esegue le due chiamate al database in parallelo
  final results = await Future.wait<dynamic>([
    // 1. Recupera i punti dell'utente
    // Correzione: La colonna ID nella tabella `utente` si chiama `idutente`.
    supabase
        .from('utente')
        .select('saldopunti')
        .eq('idutente', user.id)
        .limit(1)
        .maybeSingle(),

    // 2. Recupera la lista dei premi
    supabase.from('premio').select(),
  ]);

  // Processa i risultati
  final profileData = results[0] as Map<String, dynamic>?;
  final prizesData = results[1] as List<dynamic>;

  final int userPoints = profileData?['saldopunti'] ?? 0;

  // Converte i dati dei premi in una lista di oggetti Prize
  final List<Prize> availablePrizes = [];
  for (final item in prizesData) {
    try {
      availablePrizes.add(Prize.fromJson(item as Map<String, dynamic>));
    } catch (e) {
      // Se un premio ha dati corrotti, lo segnala nella console ma non blocca l'app
      log('ERRORE PARSING PREMIO: Dati corrotti nel DB. Dati: $item, Errore: $e');
    }
  }

  return {
    'userPoints': userPoints,
    'availablePrizes': availablePrizes,
  };
}

// --- SCHERMATA PRINCIPALE (StatefulWidget) ---

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  // Future che attende il caricamento dei dati reali
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadRealData();
  }

  /// Funzione per riscattare un premio chiamando una funzione RPC di Supabase.
  Future<void> _redeemPrize(Prize prize) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utente non autenticato.')),
      );
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Riscatto'),
        content: Text('Sei sicuro di voler riscattare "${prize.nome}" per ${prize.costoPunti} punti?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annulla')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Conferma')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // NOTA: Assicurati di aver creato la funzione `redeem_prize` nel tuo DB Supabase
      await supabase.rpc('redeem_prize', params: {
        'prize_id': prize.id,
        'user_id': user.id,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${prize.nome}" riscattato con successo!')),
      );

      // Ricarica i dati per aggiornare il saldo punti nella UI
      setState(() {
        _dataFuture = _loadRealData();
      });

    } on PostgrestException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore dal database: ${error.message}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore imprevisto durante il riscatto: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 1),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Errore nel caricamento dei dati: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Nessun dato disponibile."));
          }

          final int userPoints = snapshot.data!['userPoints'];
          final List<Prize> availablePrizes = snapshot.data!['availablePrizes'];

          return _buildContentUI(context, userPoints, availablePrizes);
        },
      ),
    );
  }

  /// Metodo che costruisce l'intera UI quando i dati sono pronti.
  Widget _buildContentUI(BuildContext context, int userPoints, List<Prize> availablePrizes) {
    final Color primaryGreen = Colors.green[700]!;
    final Color lightGreenCard = Colors.lightGreen[100]!;
    final Color iconBgGreen = Colors.lightGreen[50]!;

    return Column(
      children: [
        // --- HEADER + CARD PUNTI ---
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
              const Text("Riscatto Premi", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              _buildPointsSummaryCard(userPoints, lightGreenCard, primaryGreen),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // --- TITOLO LISTA PREMI ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text("Premi disponibili", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800])),
        ),

        // --- LISTA PREMI ---
        Expanded(
          child: availablePrizes.isEmpty
              ? const Center(child: Text("Al momento non ci sono premi disponibili."))
              : ListView.builder(
                  itemCount: availablePrizes.length,
                  itemBuilder: (context, index) {
                    final prize = availablePrizes[index];
                    return _buildPrizeCard(
                      prize: prize,
                      iconBg: iconBgGreen,
                      iconColor: primaryGreen,
                      canRedeem: userPoints >= prize.costoPunti,
                      onRedeem: () => _redeemPrize(prize),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- WIDGET HELPER ---

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

  Widget _buildPrizeCard({
    required Prize prize,
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
            // Utilizza un'icona di default dato che `iconName` non è nel modello
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

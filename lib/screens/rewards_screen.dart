import 'package:cityclean/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Palette colori (coerente con il Profilo)
    final Color primaryGreen = Colors.green[700]!;
    final Color lightGreenCard = Colors.lightGreen[100]!; // Per la card in alto
    final Color iconBgGreen = Colors.lightGreen[50]!; // Sfondo icone premi

    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 1), //RICHIAMO LA BOTTOM NAV BAR


      body: Stack(
        children: [
          // 1. SFONDO VERDE (HEADER)
          Container(
            height: 240, // Leggermente meno alto del profilo
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          // 2. CONTENUTO SCORREVOLE
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Testi Intestazione
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Riscatto Premi",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "I tuoi punti: 350",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. CARD RIEPILOGO PUNTI (Quella verde chiaro)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: lightGreenCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Punti disponibili",
                              style: TextStyle(
                                color: Colors.green[800],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "350",
                              style: TextStyle(
                                color: Colors.green[900],
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Icona stella nel cerchio verde scuro
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.star, color: Colors.white, size: 30),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Titolo Sezione "Premi disponibili"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Premi disponibili",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 4. LISTA DEI PREMI
                  // Usiamo il nostro widget helper creato sotto
                  _buildRewardCard(
                    title: "Sconto 10%",
                    points: "100 punti",
                    icon: Icons.card_giftcard,
                    iconBg: iconBgGreen,
                    iconColor: primaryGreen,
                  ),
                  _buildRewardCard(
                    title: "Prodotto Omaggio",
                    points: "250 punti",
                    icon: Icons.star_outline,
                    iconBg: iconBgGreen,
                    iconColor: primaryGreen,
                  ),
                  _buildRewardCard(
                    title: "Premio Speciale",
                    points: "500 punti",
                    icon: Icons.emoji_events_outlined,
                    iconBg: iconBgGreen,
                    iconColor: primaryGreen,
                  ),

                  const SizedBox(height: 30), // Spazio finale
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper per creare le card dei premi
  Widget _buildRewardCard({
    required String title,
    required String points,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icona a sinistra
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 15),

          // Testi (Titolo e Punti)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  points,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Bottone Riscatta
          ElevatedButton(
            onPressed: () {
              // Azione per riscattare
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor, // Colore verde scuro
              foregroundColor: Colors.white, // Colore testo bianco
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text("Riscatta"),
          ),
        ],
      ),
    );
  }
}
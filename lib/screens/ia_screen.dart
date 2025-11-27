import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';

class IAScreen extends StatefulWidget {
  const IAScreen({super.key});

  @override
  State<IAScreen> createState() => _IAScreenState();
}

class _IAScreenState extends State<IAScreen> {
  // Funzione simulata per caricare/scattare foto
  void _handleImageUpload() async {
    // 1. Qui andrebbe la logica vera (ImagePicker)
    // Per ora simuliamo un'attesa di 1.5 secondi come se stesse analizzando
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    await Future.delayed(const Duration(milliseconds: 1500));

    // Chiudiamo il caricamento
    if (mounted) Navigator.of(context).pop();

    // 2. Mostriamo la "Notifica" di successo
    if (mounted) _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text("Foto caricata!", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Foto inviata al sistema!",
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Chiude il dialog e "torna su IA"
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: const Text("Torna indietro"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;
    // Indice 4 per "IA" nella navbar
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 4),
      body: Stack(
        children: [
          // 1. HEADER VERDE
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 2. INTESTAZIONE
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Riconoscimento IA",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Identifica i rifiuti con l'intelligenza artificiale",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 3. CARD BIANCA CON CONTENUTO
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titolo Sezione
                        Row(
                          children: [
                            Icon(Icons.image_search, color: primaryGreen),
                            const SizedBox(width: 10),
                            Text(
                              "Riconosci il rifiuto",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // AREA TRASCINAMENTO / UPLOAD (Tratteggiata)
                        GestureDetector(
                          onTap: _handleImageUpload, // Simula click
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.5),
                                width: 2,
                                style: BorderStyle.solid, // Flutter non ha "dashed" nativo semplice senza pacchetti, usiamo solid o custom painter. Per semplicità usiamo solid o un verde chiaro.
                              ),
                            ),
                            // Per fare il bordo tratteggiato servirebbe un pacchetto o custom painter.
                            // Per ora usiamo un bordo solido leggero che rende l'idea.
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file, size: 50, color: primaryGreen),
                                const SizedBox(height: 15),
                                Text(
                                  "Carica un'immagine",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  "Clicca per selezionare dalla galleria",
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // BOTTONE FOTOCAMERA
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: _handleImageUpload, // Simula scatto
                            icon: const Icon(Icons.camera_alt_outlined, size: 24),
                            label: const Text(
                              "Usa la fotocamera",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Importato
import 'dart:io'; // Importato
import '../components/bottom_nav_bar.dart';

class IAScreen extends StatefulWidget {
  const IAScreen({super.key});

  @override
  State<IAScreen> createState() => _IAScreenState();
}

class _IAScreenState extends State<IAScreen> {
  File? _selectedImage; // Stato per l'immagine selezionata

  // Funzione unificata per ottenere un'immagine (da fotocamera o galleria)
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    // imageQuality riduce la dimensione del file per velocizzare l'upload
    final XFile? pickedFile = await picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile == null) return; // L'utente ha annullato la selezione

    setState(() {
      _selectedImage = File(pickedFile.path);
    });

    // Avvia la finta analisi dell'immagine
    _runAnalysis();
  }

  // Simula un processo di analisi e mostra il dialog di successo
  void _runAnalysis() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) Navigator.of(context).pop(); // Chiude il caricamento
    if (mounted) _showSuccessDialog(); // Mostra il successo
  }

  // Dialog mostrato dopo l'analisi
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text(
              "Foto analizzata!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "Il sistema ha identificato il rifiuto.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _selectedImage = null; // Rimuove l'immagine per un nuovo upload
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: const Text("Ottimo!"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;
    return Scaffold(
        backgroundColor: Colors.grey[100],
        bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 4),
        body: Stack(
          children: [
            // 1. SFONDO VERDE (HEADER)
            Container(
              height: 200,
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
                    // Titolo
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Riconoscimento IA",
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Identifica i rifiuti con l'intelligenza artificiale",
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // CARD BIANCA
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: Column(
                        children: [
                          // AREA DI UPLOAD / VISUALIZZAZIONE
                          GestureDetector(
                            onTap: () => _pickImage(ImageSource.gallery), // Apre la galleria
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.green.withOpacity(0.5), width: 2),
                              ),
                              child: _selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(18.0),
                                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.upload_file, size: 50, color: primaryGreen),
                                        const SizedBox(height: 15),
                                        Text("Carica un'immagine", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800])),
                                        const SizedBox(height: 5),
                                        const Text("Clicca per selezionare dalla galleria", style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
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
                              onPressed: () => _pickImage(ImageSource.camera), // Apre la fotocamera
                              icon: const Icon(Icons.camera_alt_outlined, size: 24),
                              label: const Text("Usa la fotocamera", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

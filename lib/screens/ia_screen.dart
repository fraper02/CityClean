import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../components/bottom_nav_bar.dart';
import '../controllers/ia_controller.dart';
import '../models/bin_info.dart';
import '../models/classification_result.dart';

class IAScreen extends StatefulWidget {
  const IAScreen({super.key});

  @override
  State<IAScreen> createState() => _IAScreenState();
}

class _IAScreenState extends State<IAScreen> {
  late final IAController _controller;

  // SEMAFORO: Impedisce l'apertura di dialoghi multipli sovrapposti
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _controller = IAController();
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      // 1. SE UN DIALOGO È GIÀ APERTO, BLOCCA TUTTO ED ESCI.
      if (_isDialogShowing) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Controllo di sicurezza: se nel frattempo si è aperto un dialogo, esci
        if (_isDialogShowing) return;

        // GESTIONE ERRORE
        if (_controller.error != null) {
          _isDialogShowing = true; // Attiva il semaforo
          _showErrorDialog(_controller.error!);
          return;
        }

        // GESTIONE RISULTATO
        if (_controller.classificationResult != null && _controller.binInfo != null && !_controller.isLoading) {
          _isDialogShowing = true; // Attiva il semaforo
          _showResultDialog(
            _controller.classificationResult!,
            _controller.binInfo!,
          );
          return;
        }
      });

      // Aggiorna l'interfaccia (sfondo, caricamento) solo se non stiamo aprendo un dialogo
      setState(() {});
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false, // Impedisce di chiudere cliccando fuori senza resettare
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 10),
            Text('Attenzione'),
          ],
        ),
        content: Text(errorMessage, style: const TextStyle(fontSize: 16)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(ctx).pop();
              _controller.clearError();
            },
          ),
        ],
      ),
    ).then((_) {
      // Quando il dialogo si chiude (in qualsiasi modo), sblocca il semaforo
      _isDialogShowing = false;
    });
  }

  void _showResultDialog(ClassificationResult result, BinInfo binInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icona Cerchiata
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: binInfo.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(binInfo.icon, color: binInfo.color, size: 60),
              ),
              const SizedBox(height: 20),

              // Titolo Rifiuto
              Text(
                result.label.toUpperCase().replaceAll('_', ' '),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: 1.0),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // Barra Confidenza
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Affidabilità: ", style: TextStyle(color: Colors.grey)),
                  Text(
                    "${result.confidence > 1 ? result.confidence.toStringAsFixed(0) : (result.confidence * 100).toStringAsFixed(0)}%",
                    style: TextStyle(fontWeight: FontWeight.bold, color: binInfo.color),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: result.confidence > 1 ? result.confidence / 100 : result.confidence,
                  backgroundColor: Colors.grey[200],
                  color: binInfo.color,
                  minHeight: 6,
                ),
              ),

              const Divider(height: 40),

              const Text("Va gettato nel:", style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 8),

              // Pillola Destinazione
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: binInfo.color,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: binInfo.color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                  ],
                ),
                child: Text(
                  binInfo.binName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),

              const SizedBox(height: 20),

              // Bottone Chiudi
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[300]!)),
                  ),
                  onPressed: () {
                    // Reset e chiusura
                    _controller.reset(); // Resetta i dati PRIMA di chiudere
                    Navigator.of(ctx).pop();
                  },
                  child: const Text("CHIUDI", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      // Quando il dialogo si chiude, sblocca il semaforo
      _isDialogShowing = false;

      // Se l'utente ha chiuso il dialog cliccando "indietro" sul telefono invece che "Chiudi",
      // assicuriamoci che il controller venga resettato per non riaprire il dialog.
      if (_controller.classificationResult != null) {
        _controller.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;
    const bool isMaestroTest = bool.fromEnvironment('MAESTRO_TEST');

    return Scaffold(
        backgroundColor: Colors.grey[50],
        bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 4),
        body: Stack(
          children: [
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green[800]!, Colors.green[600]!],
                ),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                              const SizedBox(width: 10),
                              const Text("Eco Scanner", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text("Inquadra un rifiuto per scoprire dove buttarlo.", style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.4)),
                          if (isMaestroTest)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                              child: const Text('TEST MODE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[200]!, width: 2),
                            ),
                            // QUI VIENE COSTRUITO IL CONTENUTO DELL'IMMAGINE
                            child: _buildContent(primaryGreen),
                          ),
                          const SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: Semantics(
                              identifier: 'ia_camera_button',
                              child: ElevatedButton.icon(
                                onPressed: (_controller.isLoading || !_controller.isModelLoaded)
                                    ? null
                                    : () => _controller.pickAndClassifyImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt, size: 26),
                                label: const Text("SCATTA FOTO", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  elevation: 4,
                                  shadowColor: primaryGreen.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "Assicurati che l'oggetto sia ben illuminato",
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  // --- MODIFICA QUI ---
  Widget _buildContent(Color primaryGreen) {
    if (!_controller.isModelLoaded && _controller.isLoading) {
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryGreen),
              const SizedBox(height: 15),
              Text("Caricamento intelligenza...", style: TextStyle(color: Colors.grey[600]))
            ],
          )
      );
    }

    if (_controller.selectedImage != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // 1. L'immagine di sfondo
          ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: Image.file(_controller.selectedImage!, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
          ),

          // 2. Indicatore di caricamento (se attivo)
          if (_controller.isLoading)
            Container(
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // 3. PULSANTE DI CHIUSURA (X) ROSSO ELEGANTE
          if (!_controller.isLoading)
            Positioned(
              top: 12,
              right: 12,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _controller.reset(),
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      // MODIFICA QUI: Colore rosso intenso semi-trasparente
                      color: Colors.red[700]!.withOpacity(0.75),
                      shape: BoxShape.circle,
                      // Bordo bianco leggermente più visibile per contrasto
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      // Stato iniziale: pulsante per caricare dalla galleria
      return Semantics(
        identifier: 'ia_upload_button',
        child: InkWell(
          onTap: () => _controller.pickAndClassifyImage(ImageSource.gallery),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_rounded, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 15),
              Text("Tocca per caricare dalla galleria", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[400])),
            ],
          ),
        ),
      );
    }
  }
}
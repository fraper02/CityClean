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
    // If a result is available, show the dialog
    if (_controller.classificationResult != null && !_controller.isLoading) {
      // Use a post-frame callback to ensure the build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showResultDialog(
            _controller.classificationResult!,
            _controller.binInfo!,
          );
        }
      });
    } else {
      // Otherwise, just rebuild the widget tree
      setState(() {});
    }
  }

  void _showResultDialog(ClassificationResult result, BinInfo binInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Rifiuto Riconosciuto!", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(binInfo.icon, color: binInfo.color, size: 80),
            const SizedBox(height: 16),
            Text(result.label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 4),
            Text("Confidenza: ${result.confidence.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),
            const Text("Contenitore corretto:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: binInfo.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: binInfo.color, width: 1.5),
              ),
              child: Text(
                binInfo.binName,
                style: TextStyle(fontWeight: FontWeight.bold, color: binInfo.color, fontSize: 18),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _controller.reset();
            },
            child: const Text("HO CAPITO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Riconoscimento IA", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(height: 5),
                          Text("Identifica i rifiuti con l'intelligenza artificiale", style: TextStyle(fontSize: 16, color: Colors.white70)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
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
                          Container(
                            width: double.infinity,
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green.withOpacity(0.5), width: 2),
                            ),
                            child: _buildContent(primaryGreen),
                          ),
                          const SizedBox(height: 20),
                          if (_controller.error != null)
                             Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                              decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(15)),
                              child: Text(_controller.error!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red[900]), textAlign: TextAlign.center),
                            ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton.icon(
                              onPressed: (_controller.isLoading || !_controller.isModelLoaded)
                                  ? null
                                  : () => _controller.pickAndClassifyImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt_outlined, size: 24),
                              label: const Text("Usa la fotocamera", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 2),
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

  Widget _buildContent(Color primaryGreen) {
    if (!_controller.isModelLoaded && _controller.isLoading) {
       return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 10), Text("Caricamento modello...")],));
    }

    if (_controller.error != null && _controller.selectedImage == null) {
      return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_controller.error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center)));
    }

    if (_controller.selectedImage != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: Image.file(_controller.selectedImage!, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
          ),
          if (_controller.isLoading)
            const CircularProgressIndicator(color: Colors.white),
        ],
      );
    } else {
      return GestureDetector(
        onTap: () => _controller.pickAndClassifyImage(ImageSource.gallery),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file, size: 50, color: primaryGreen),
            const SizedBox(height: 15),
            Text("Carica un'immagine", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800])),
            const SizedBox(height: 5),
            const Text("Clicca per selezionare dalla galleria", style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      );
    }
  }
}

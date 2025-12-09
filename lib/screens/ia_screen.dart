import 'dart:io';
// Necessario per Float32List se usato, o List standard
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
// Assicurati che questo import sia corretto nel tuo progetto
import '../components/bottom_nav_bar.dart';

class IAScreen extends StatefulWidget {
  const IAScreen({super.key});

  @override
  State<IAScreen> createState() => _IAScreenState();
}

class _IAScreenState extends State<IAScreen> {
  File? _selectedImage;
  Interpreter? _interpreter;
  List<String> _labels = [];
  String _classificationResult = "";
  bool _isLoading = true;
  String? _loadingError;

  static const int INPUT_SIZE = 224;
  // Assicurati che il tuo file labels.txt abbia esattamente 12 righe
  static const int NUM_CLASSES = 12;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      // Opzioni per l'interprete (opzionale, ma consigliato)
      final options = InterpreterOptions();

      _interpreter = await Interpreter.fromAsset('assets/ml/yolo_model_best.tflite', options: options);

      final labelsData = await rootBundle.loadString('assets/ml/yolo_labels.txt');
      // Correzione split: rimuove spazi e gestisce i fine riga correttamente
      _labels = labelsData.split('\n').where((label) => label.trim().isNotEmpty).toList();

      if (_labels.length != NUM_CLASSES) {
        // Nota: Questo è un warning, se hai classi diverse aggiorna NUM_CLASSES
        debugPrint("Warning: Caricate ${_labels.length} etichette, ma NUM_CLASSES è $NUM_CLASSES.");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingError = "Errore caricamento modello: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source, imageQuality: 80);

      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
        _classificationResult = "";
        _loadingError = null;
      });

      // Avvia la classificazione dopo aver settato l'immagine
      await _classifyImage(_selectedImage!);
    } catch (e) {
      setState(() {
        _loadingError = "Errore selezione immagine: $e";
      });
    }
  }

  Future<void> _classifyImage(File imageFile) async {
    if (_interpreter == null) {
      setState(() => _loadingError = "Modello non caricato.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Decodifica Immagine
      final imageBytes = await imageFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception("Impossibile decodificare l'immagine.");
      }

      // 2. Ridimensionamento (224x224)
      final img.Image resizedImage = img.copyResize(originalImage, width: INPUT_SIZE, height: INPUT_SIZE);

      // 3. Preparazione Input [1, 224, 224, 3]
      // Creiamo una matrice 4D direttamente invece di usare reshape su un array piatto
      var input = List.generate(1, (batch) =>
          List.generate(INPUT_SIZE, (y) =>
              List.generate(INPUT_SIZE, (x) {
                var pixel = resizedImage.getPixel(x, y);
                // Normalizzazione standard 0.0 - 1.0 (RGB)
                return [
                  pixel.r / 255.0,
                  pixel.g / 255.0,
                  pixel.b / 255.0
                ];
              })
          )
      );

      // 4. Preparazione Output [1, NUM_CLASSES]
      // Assicurati che la shape corrisponda a quella del tuo modello (usa Netron per verificare se serve)
      var output = List.generate(1, (index) => List.filled(NUM_CLASSES, 0.0));

      // 5. Inferenza
      _interpreter!.run(input, output);

      // 6. Elaborazione Risultati
      final List<double> results = output[0];
      int maxIndex = -1;
      double maxScore = -1.0;

      for (int i = 0; i < results.length; i++) {
        if (results[i] > maxScore) {
          maxScore = results[i];
          maxIndex = i;
        }
      }

      if (maxIndex != -1 && _labels.isNotEmpty && maxIndex < _labels.length) {
        final recognizedLabel = _labels[maxIndex];
        final confidence = maxScore * 100;

        // Mostra il dialog solo se il widget è ancora montato
        if (mounted) {
          _showResultDialog(recognizedLabel, confidence);
        }
      } else {
        throw Exception("Nessuna classificazione valida o indice fuori dai limiti.");
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingError = "Errore classificazione: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _getBinInfo(String material) {
    final String lowerCaseMaterial = material.toLowerCase();

    if (lowerCaseMaterial.contains('plastic') || lowerCaseMaterial.contains('metal')) {
      return {'binName': 'PLASTICA E METALLI', 'color': Colors.yellow[800]!, 'icon': Icons.recycling};
    }
    if (lowerCaseMaterial.contains('paper')) {
      return {'binName': 'CARTA E CARTONE', 'color': Colors.blue[800]!, 'icon': Icons.description};
    }
    if (lowerCaseMaterial.contains('glass')) {
      return {'binName': 'VETRO', 'color': Colors.green[800]!, 'icon': Icons.wine_bar};
    }
    if (lowerCaseMaterial.contains('organic')) {
      return {'binName': 'ORGANICO / UMIDO', 'color': Colors.brown[800]!, 'icon': Icons.eco};
    }
    if (lowerCaseMaterial.contains('e-waste') ||
        lowerCaseMaterial.contains('battery') ||
        lowerCaseMaterial.contains('bulb') ||
        lowerCaseMaterial.contains('automobile') ||
        lowerCaseMaterial.contains('clothes') ||
        lowerCaseMaterial.contains('shoes')) {
      return {'binName': 'ISOLA ECOLOGICA', 'color': Colors.red[800]!, 'icon': Icons.electrical_services};
    }
    return {'binName': 'INDIFFERENZIATO / SECCO', 'color': Colors.grey[800]!, 'icon': Icons.delete};
  }

  void _showResultDialog(String material, double confidence) {
    final binInfo = _getBinInfo(material);
    final String binName = binInfo['binName'];
    final Color binColor = binInfo['color'];
    final IconData binIcon = binInfo['icon'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Rifiuto Riconosciuto!", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(binIcon, color: binColor, size: 80),
            const SizedBox(height: 16),
            Text(material.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 4),
            Text("Confidenza: ${confidence.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),
            const Text("Contenitore corretto:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: binColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: binColor, width: 1.5),
              ),
              child: Text(
                binName,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: binColor, fontSize: 18),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _selectedImage = null;
                _classificationResult = "";
                _loadingError = null;
              });
            },
            child: const Text("HO CAPITO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  // --- WIDGET BUILDER ---

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;

    return Scaffold(
        backgroundColor: Colors.grey[100],
        // Se non hai il file bottom_nav_bar.dart, commenta questa riga
        bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 4),
        body: Stack(
          children: [
            // Sfondo verde superiore
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
                            // Chiamata al metodo completato
                            child: _buildContent(primaryGreen),
                          ),
                          const SizedBox(height: 20),

                          // Messaggi di errore se presenti
                          if (_loadingError != null && _classificationResult.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                              decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(15)),
                              child: Text(_loadingError!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red[900]), textAlign: TextAlign.center),
                            ),
                          const SizedBox(height: 30),

                          // Bottone Fotocamera
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton.icon(
                              onPressed: (_isLoading || _interpreter == null) ? null : () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt_outlined, size: 24),
                              label: const Text("Usa la fotocamera", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 2),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Bottone Galleria (Opzionale, aggiunto per comodità)
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton.icon(
                              onPressed: (_isLoading || _interpreter == null) ? null : () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_outlined, size: 24),
                              label: const Text("Carica dalla galleria", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(foregroundColor: primaryGreen, side: BorderSide(color: primaryGreen, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
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

  // Metodo completato
  Widget _buildContent(Color primaryGreen) {
    if (_interpreter == null && _loadingError == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_interpreter == null && _loadingError != null) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 10),
                  Text("Errore Inizializzazione:\n$_loadingError", style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                ],
              )
          )
      );
    }

    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryGreen),
          const SizedBox(height: 15),
          Text("Analisi in corso...", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
        ],
      );
    }

    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_search, size: 60, color: Colors.green[300]),
        const SizedBox(height: 10),
        Text("Nessuna immagine selezionata", style: TextStyle(color: Colors.green[700], fontSize: 16)),
      ],
    );
  }
}
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/bin_info.dart';
import '../models/classification_result.dart';
import '../services/tflite_service.dart';
import '../services/waste_bin_service.dart';

class IAController with ChangeNotifier {
  final TFLiteService _tfliteService = TFLiteService();
  final WasteBinService _wasteBinService = WasteBinService();
  final ImagePicker _picker = ImagePicker();

  // ... (Variabili e Getter) ...
  File? _selectedImage;
  ClassificationResult? _classificationResult;
  BinInfo? _binInfo;
  bool _isLoading = false;
  bool _isModelLoaded = false;
  String? _error;

  File? get selectedImage => _selectedImage;
  ClassificationResult? get classificationResult => _classificationResult;
  BinInfo? get binInfo => _binInfo;
  bool get isLoading => _isLoading;
  bool get isModelLoaded => _isModelLoaded;
  String? get error => _error;
  // ... (Fine Variabili e Getter) ...

  IAController() {
    _loadModel();
  }

  // ... (Metodo _loadModel) ...
  Future<void> _loadModel() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _tfliteService.loadModel();
      _isModelLoaded = true;
    } catch (e) {
      _error = "Errore nel caricamento del modello AI.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // ... (Fine _loadModel) ...


  Future<void> pickAndClassifyImage(ImageSource source) async {
    _isLoading = true;
    _error = null;
    _classificationResult = null;
    notifyListeners();

    try {
      XFile? pickedFile;
      // Legge la variabile d'ambiente di compilazione
      const bool isMaestroTest = false;

      if (isMaestroTest) {
        // --- LOGICA DI BYPASS PER MAESTRO ---
        try {
          // 1. Carica i dati dell'immagine dall'asset
          const String assetPath = 'assets/images/test_image.png';
          final byteData = await rootBundle.load(assetPath);

          // 2. Crea un file temporaneo per simulare un'immagine selezionata
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/test_image_maestro.png'); // Nome file univoco

          // 3. Scrivi i dati nel file temporaneo
          await file.writeAsBytes(
              byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes)
          );

          // 4. Utilizza il percorso del file temporaneo come se fosse stato selezionato
          pickedFile = XFile(file.path);

        } on FlutterError {
          // Cattura l'errore se l'asset non è presente
          _error = "IMMAGINE DI TEST MANCANTE: Assicurati che esista e sia nel pubspec.yaml.";
          _isLoading = false;
          notifyListeners();
          return;
        }
        // ------------------------------------
      } else {
        // --- LOGICA NORMALE (Galleria/Fotocamera) ---
        pickedFile = await _picker.pickImage(source: source);
      }

      _selectedImage = File(pickedFile.path);
      notifyListeners(); // Mostra l'immagine immediatamente

      // CLASSIFICAZIONE
      final result = await _tfliteService.classifyImage(_selectedImage!);
      if (result != null) {
        _classificationResult = result;
        _binInfo = await _wasteBinService.getBinInfoForLabel(result.label);
      } else {
        _error = "Impossibile classificare l'immagine.";
      }
    } catch (e) {
      _error = "Si è verificato un errore: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ... (Metodi reset e dispose) ...
  void reset() {
    _selectedImage = null;
    _classificationResult = null;
    _binInfo = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }
}
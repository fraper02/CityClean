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

  IAController() {
    _loadModel();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

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

  Future<void> pickAndClassifyImage(ImageSource source) async {
    _isLoading = true;
    _error = null;
    _classificationResult = null;
    _binInfo = null;
    notifyListeners();

    try {
      XFile? pickedFile;
      const bool isMaestroTest = bool.fromEnvironment('MAESTRO_TEST');

      if (isMaestroTest) {
        try {
          const String assetPath = 'assets/images/test_image.png';
          final byteData = await rootBundle.load(assetPath);
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/test_image_maestro.png');
          await file.writeAsBytes(
              byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes)
          );
          pickedFile = XFile(file.path);
        } on FlutterError {
          _error = "IMMAGINE DI TEST MANCANTE: Assicurati che esista e sia nel pubspec.yaml.";
        }
      } else {
        pickedFile = await _picker.pickImage(source: source);
      }

      if (pickedFile == null) {
        // L'utente ha annullato la selezione, ripristiniamo lo stato di loading
        _isLoading = false;
        notifyListeners();
        return;
      }

      _selectedImage = File(pickedFile.path);
      notifyListeners();

      final result = await _tfliteService.classifyImage(_selectedImage!);

      if (result != null) {
        // CORREZIONE LOGICA CONFIDENZA
        // Se il modello restituisce valori su scala 0-100 (es. 38.0), usiamo 55.0 come soglia.
        // Se il modello restituisce valori su scala 0-1 (es. 0.38), usiamo 0.55 come soglia.
        bool isConfident = false;
        if (result.confidence > 1.0) {
          isConfident = result.confidence > 45.0; // Scala percentuale
        } else {
          isConfident = result.confidence > 0.45; // Scala decimale
        }

        if (isConfident) {
          _classificationResult = result;
          _binInfo = await _wasteBinService.getBinInfoForLabel(result.label);
        } else {
          _error = "Rifiuto non riconosciuto. Prova con un'altra immagine!";
          _classificationResult = null;
          _binInfo = null;
        }
      } else {
        _error = "Impossibile classificare l'immagine. Riprova.";
      }

    } catch (e) {
      _error = "Si è verificato un errore inaspettato: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
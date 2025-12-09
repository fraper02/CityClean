import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/bin_info.dart';
import '../models/classification_result.dart';
import '../services/tflite_service.dart';
import '../services/waste_bin_service.dart';

class IAController with ChangeNotifier {
  final TFLiteService _tfliteService = TFLiteService();
  final WasteBinService _wasteBinService = WasteBinService(); // MODIFICATO
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  ClassificationResult? _classificationResult;
  BinInfo? _binInfo;
  bool _isLoading = false;
  String? _error;
  bool _isModelLoaded = false;

  File? get selectedImage => _selectedImage;
  ClassificationResult? get classificationResult => _classificationResult;
  BinInfo? get binInfo => _binInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isModelLoaded => _isModelLoaded;

  IAController() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    _setLoading(true);
    try {
      await _tfliteService.loadModel();
      _isModelLoaded = true;
      _error = null;
    } catch (e) {
      _error = "Errore durante il caricamento del modello: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> pickAndClassifyImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile == null) return;

      _selectedImage = File(pickedFile.path);
      _setLoading(true);
      _error = null;
      _classificationResult = null;
      _binInfo = null;
      notifyListeners();

      final result = await _tfliteService.classifyImage(_selectedImage!);
      
      if (result != null) {
        _classificationResult = result;
        // MODIFICATO: Ora usa il servizio che chiama il DB
        _binInfo = await _wasteBinService.getBinInfoForLabel(result.label);
      } else {
        _error = "Impossibile classificare l'immagine.";
      }
    } catch (e) {
      _error = "Errore durante la classificazione: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }
  
  void reset() {
    _selectedImage = null;
    _classificationResult = null;
    _binInfo = null;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }
}

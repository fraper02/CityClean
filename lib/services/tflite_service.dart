import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../models/classification_result.dart';

class TFLiteService {
  static const int INPUT_SIZE = 224;
  // RIPORTATO A 9 PER TEST INTERFACCIA
  static const int NUM_CLASSES = 12;

  Interpreter? _interpreter;
  List<String> _labels = [];

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/ml/yolo_model_best.tflite');
      final labelsData = await rootBundle.loadString('assets/ml/yolo_labels.txt');
      _labels = labelsData.split('\n').where((label) => label.trim().isNotEmpty).toList();

      if (_labels.length != NUM_CLASSES) {
        throw Exception("Il numero di etichette (${_labels.length}) non corrisponde a NUM_CLASSES ($NUM_CLASSES).");
      }
    } catch (e) {
      print("Errore caricamento modello: $e");
      rethrow;
    }
  }

  Future<ClassificationResult?> classifyImage(File imageFile) async {
    if (_interpreter == null) {
      await loadModel();
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception("Impossibile decodificare l'immagine.");
      }

      final img.Image resizedImage = img.copyResize(originalImage, width: INPUT_SIZE, height: INPUT_SIZE);
      
      var buffer = Float32List(1 * INPUT_SIZE * INPUT_SIZE * 3);
      var bufferIndex = 0;
      for (var y = 0; y < INPUT_SIZE; y++) {
        for (var x = 0; x < INPUT_SIZE; x++) {
          var pixel = resizedImage.getPixel(x, y);
          buffer[bufferIndex++] = pixel.rNormalized.toDouble();
          buffer[bufferIndex++] = pixel.gNormalized.toDouble();
          buffer[bufferIndex++] = pixel.bNormalized.toDouble();
        }
      }

      final input = buffer.reshape([1, INPUT_SIZE, INPUT_SIZE, 3]);
      final output = List.generate(1, (i) => List.filled(NUM_CLASSES, 0.0));

      _interpreter!.run(input, output);
      
      final List<double> results = output[0];
      int maxIndex = -1;
      double maxScore = -1.0;

      for (int i = 0; i < results.length; i++) {
        if (results[i] > maxScore) {
          maxScore = results[i];
          maxIndex = i;
        }
      }

      if (maxIndex != -1) {
        final recognizedLabel = _labels[maxIndex];
        final confidence = maxScore * 100;
        return ClassificationResult(label: recognizedLabel, confidence: confidence);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Errore classificazione: $e");
      rethrow;
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}

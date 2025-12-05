import 'package:cityclean/models/obiettivo.dart';
import 'package:cityclean/services/objective_service.dart';
import 'package:flutter/material.dart';

enum ObjectivesScreenState { initial, loading, success, error }

class ObjectivesController {
  final ObjectiveService _service;

  final ValueNotifier<ObjectivesScreenState> state = ValueNotifier(ObjectivesScreenState.initial);
  final ValueNotifier<List<Obiettivo>> availableObjectives = ValueNotifier([]);
  final ValueNotifier<List<Obiettivo>> completedObjectives = ValueNotifier([]);
  final ValueNotifier<String> errorMessage = ValueNotifier('');

  ObjectivesController({ObjectiveService? service}) : _service = service ?? ObjectiveService();

  Future<void> loadObjectives() async {
    state.value = ObjectivesScreenState.loading;
    try {
      final allObjectives = await _service.getAllObjectivesWithStatus();

      // Dividiamo gli obiettivi nelle due liste
      availableObjectives.value = allObjectives.where((obj) => !obj.isConseguito).toList();
      completedObjectives.value = allObjectives.where((obj) => obj.isConseguito).toList();

      state.value = ObjectivesScreenState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = ObjectivesScreenState.error;
    }
  }

  void showObjectiveDetails(BuildContext context, Obiettivo obiettivo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Row(
            children: [
              obiettivo.isConseguito
                  ? Icon(Icons.check_circle, color: Colors.green[700])
                  : Icon(Icons.emoji_events_outlined, color: Colors.amber[800]),
              const SizedBox(width: 10),
              Expanded(child: Text(obiettivo.nome, style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          content: Text(obiettivo.descrizione.isNotEmpty
              ? obiettivo.descrizione
              : "Nessuna descrizione per questo obiettivo."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Chiudi'),
            ),
          ],
        );
      },
    );
  }

  void dispose() {
    state.dispose();
    availableObjectives.dispose();
    completedObjectives.dispose();
    errorMessage.dispose();
  }
}

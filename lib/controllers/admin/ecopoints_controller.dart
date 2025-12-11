import 'package:cityclean/models/ecopoint.dart';
import 'package:cityclean/services/admin/ecopoints_service.dart';
import 'package:flutter/material.dart';

enum EcopointsState { initial, loading, success, error }

class EcopointsController {
  final EcopointsService _service;

  final ValueNotifier<EcopointsState> state = ValueNotifier(EcopointsState.initial);
  final ValueNotifier<List<Ecopoint>> ecopoints = ValueNotifier([]);
  final ValueNotifier<String> errorMessage = ValueNotifier('');

  EcopointsController({EcopointsService? service}) : _service = service ?? EcopointsService();

  Future<void> loadEcopoints() async {
    state.value = EcopointsState.loading;
    try {
      ecopoints.value = await _service.getEcopoints();
      state.value = EcopointsState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = EcopointsState.error;
    }
  }

  Future<void> createEcopoint(BuildContext context, Ecopoint newEcopoint) async {
    try {
      await _service.createEcopoint(newEcopoint);
      await loadEcopoints(); // Ricarica la lista
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ecopunto creato con successo!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nella creazione: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> updateEcopoint(BuildContext context, Ecopoint updatedEcopoint) async {
    try {
      await _service.updateEcopoint(updatedEcopoint);
      await loadEcopoints(); // Ricarica la lista
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ecopunto aggiornato con successo!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nell\'aggiornamento: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> deleteEcopoint(BuildContext context, String id) async {
    try {
      await _service.deleteEcopoint(id);
      await loadEcopoints(); // Ricarica la lista
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ecopunto eliminato.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nell\'eliminazione: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  void dispose() {
    state.dispose();
    ecopoints.dispose();
    errorMessage.dispose();
  }
}

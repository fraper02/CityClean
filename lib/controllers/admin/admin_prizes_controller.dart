import 'package:cityclean/models/partner.dart';
import 'package:cityclean/models/prizes.dart';
import 'package:cityclean/services/admin/admin_prizes_service.dart';
import 'package:flutter/material.dart';

enum AdminPrizesState { initial, loading, success, error }

class AdminPrizesController {
  final AdminPrizesService _service;

  final ValueNotifier<AdminPrizesState> state = ValueNotifier(AdminPrizesState.initial);
  final ValueNotifier<List<Prize>> prizes = ValueNotifier([]);
  final ValueNotifier<List<Partner>> partners = ValueNotifier([]);
  final ValueNotifier<String> errorMessage = ValueNotifier('');

  AdminPrizesController({AdminPrizesService? service}) : _service = service ?? AdminPrizesService();

  Future<void> loadAll() async {
    state.value = AdminPrizesState.loading;
    try {
      final results = await Future.wait([
        _service.getPrizes(),
        _service.getPartners(),
      ]);
      prizes.value = results[0] as List<Prize>;
      partners.value = results[1] as List<Partner>;
      state.value = AdminPrizesState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = AdminPrizesState.error;
    }
  }

  // --- Metodi per i Premi ---
  Future<void> createPrize(BuildContext context, Prize prize) async {
    await _handleOperation(context, () => _service.createPrize(prize), "Premio creato con successo!");
  }

  Future<void> updatePrize(BuildContext context, Prize prize) async {
    await _handleOperation(context, () => _service.updatePrize(prize), "Premio aggiornato con successo!");
  }

  Future<void> deletePrize(BuildContext context, String id) async {
    await _handleOperation(context, () => _service.deletePrize(id), "Premio eliminato.", isDelete: true);
  }

  // --- Metodi per i Partner ---
  Future<void> createPartner(BuildContext context, Partner partner) async {
    await _handleOperation(context, () => _service.createPartner(partner), "Partner creato con successo!");
  }

  Future<void> updatePartner(BuildContext context, Partner partner) async {
    await _handleOperation(context, () => _service.updatePartner(partner), "Partner aggiornato con successo!");
  }

  Future<void> deletePartner(BuildContext context, String id) async {
    await _handleOperation(context, () => _service.deletePartner(id), "Partner eliminato.", isDelete: true);
  }

  // Metodo helper generico per gestire le operazioni
  Future<void> _handleOperation(BuildContext context, Future<void> Function() operation, String successMessage, {bool isDelete = false}) async {
    try {
      await operation();
      await loadAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage), backgroundColor: isDelete ? Colors.orange : Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void dispose() {
    state.dispose();
    prizes.dispose();
    partners.dispose();
    errorMessage.dispose();
  }
}

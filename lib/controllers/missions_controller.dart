import 'package:cityclean/models/missione.dart';
import 'package:cityclean/services/mission_service.dart';
import 'package:flutter/material.dart';

enum MissionsScreenState { initial, loading, success, error }

class MissionsController {
  final MissionService _service;

  final ValueNotifier<MissionsScreenState> state = ValueNotifier(MissionsScreenState.initial);
  final ValueNotifier<List<Missione>> missions = ValueNotifier([]);
  final ValueNotifier<String> errorMessage = ValueNotifier('');

  MissionsController({MissionService? service}) : _service = service ?? MissionService();

  Future<void> loadMissions() async {
    state.value = MissionsScreenState.loading;
    try {
      missions.value = await _service.getAllMissionsWithStatus();
      state.value = MissionsScreenState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = MissionsScreenState.error;
    }
  }

  Future<void> acceptMission(BuildContext context, String missionId) async {
    try {
      await _service.acceptMission(missionId);
      // Ricarica la lista per mostrare lo stato aggiornato
      await loadMissions();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Missione accettata! Buon lavoro.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void dispose() {
    state.dispose();
    missions.dispose();
    errorMessage.dispose();
  }
}

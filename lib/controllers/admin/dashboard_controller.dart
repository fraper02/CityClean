import 'package:cityclean/services/admin/dashboard_service.dart';
import 'package:flutter/foundation.dart';

enum DashboardState { initial, loading, success, error }

class DashboardController {
  final DashboardService _service;

  final ValueNotifier<DashboardState> state = ValueNotifier(DashboardState.initial);
  final ValueNotifier<int> totalUsers = ValueNotifier(0);
  final ValueNotifier<int> openReports = ValueNotifier(0);
  final ValueNotifier<String> errorMessage = ValueNotifier('');

  DashboardController({DashboardService? service}) : _service = service ?? DashboardService();

  Future<void> loadDashboardData() async {
    state.value = DashboardState.loading;
    try {
      // Carica i dati in parallelo per ottimizzare i tempi
      final results = await Future.wait([
        _service.getTotalUsers(),
        _service.getOpenReportsCount(),
      ]);

      totalUsers.value = results[0];
      openReports.value = results[1];

      state.value = DashboardState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = DashboardState.error;
    }
  }

  void dispose() {
    state.dispose();
    totalUsers.dispose();
    openReports.dispose();
    errorMessage.dispose();
  }
}

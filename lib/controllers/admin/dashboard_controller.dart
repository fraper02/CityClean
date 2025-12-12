import 'dart:convert';
import 'dart:io';
import 'package:cityclean/models/admin_dashboard_stats.dart';
import 'package:cityclean/services/admin/dashboard_service.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum DashboardState { initial, loading, success, error }

class DashboardController {
  final DashboardService _service = DashboardService();

  final state = ValueNotifier(DashboardState.initial);
  final errorMessage = ValueNotifier('');
  final timeRange = ValueNotifier(StatsTimeRange.allTime);

  final stats = ValueNotifier(AdminDashboardStats.zero());
  final chartData = ValueNotifier<Map<String, dynamic>>({'conferimenti': [], 'segnalazioni': []});

  Future<void> loadData() async {
    state.value = DashboardState.loading;
    try {
      final data = await _service.fetchDashboardData(range: timeRange.value);
      if (data.isNotEmpty) {
        stats.value = AdminDashboardStats.fromJson(data['stats'] as Map<String, dynamic>);
        chartData.value = data['charts'] as Map<String, dynamic>;
      }
      state.value = DashboardState.success;
    } catch (e) {
      errorMessage.value = "Errore nel caricamento: ${e.toString()}";
      state.value = DashboardState.error;
    }
  }

  void setTimeRange(StatsTimeRange newRange) {
    if (timeRange.value != newRange) {
      timeRange.value = newRange;
      loadData();
    }
  }

  // Metodo UNIFICATO per l'esportazione, corretto e multipiattaforma
  Future<bool> exportReport() async {
    final data = chartData.value;
    final conferimenti = data['conferimenti'] as List? ?? [];
    final segnalazioni = data['segnalazioni'] as List? ?? [];

    if (conferimenti.isEmpty && segnalazioni.isEmpty) {
      errorMessage.value = "Nessun dato da esportare.";
      return false;
    }

    List<List<dynamic>> rows = [];
    rows.add(["Tipo", "Data", "Valore/Punti", "CO2 (kg)", "Stato", "Accettata"]);

    for (var item in conferimenti) {
      rows.add(["Conferimento", item['data_conferimento'], item['punti_guadagnati'], item['peso_co2_totale'], 'N/A', 'N/A']);
    }
    for (var item in segnalazioni) {
      rows.add(["Segnalazione", item['datacreazione'], 'N/A', 'N/A', item['stato'], item['accettata']]);
    }
    final csv = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csv);
    final fileName = "report_cityclean_${DateTime.now().toIso8601String()}.csv";

    try {
        // Questa è la soluzione moderna e corretta. Su mobile apre il pannello
        // di condivisione, su desktop apre il dialog "Salva con nome".
        final result = await Share.shareXFiles(
            [XFile.fromData(bytes, name: fileName, mimeType: 'text/csv')],
            subject: 'Report CityClean',
        );

        return result.status == ShareResultStatus.success || result.status == ShareResultStatus.dismissed;
    } catch (e) {
        errorMessage.value = "Errore durante la creazione del file: $e";
        return false;
    }
  }

  void dispose() {
    state.dispose();
    errorMessage.dispose();
    timeRange.dispose();
    stats.dispose();
    chartData.dispose();
  }
}

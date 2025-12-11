import 'package:cityclean/controllers/admin/dashboard_controller.dart';
import 'package:cityclean/services/admin/dashboard_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color adminPrimaryColor = Color(0xFF2E7D32);
const Color adminAccentColor = Color(0xFF66BB6A);

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    _controller.loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleExport() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Preparazione del report in corso...')));
    final success = await _controller.exportReport();
    scaffoldMessenger.removeCurrentSnackBar();
    if (!success) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Errore: ${_controller.errorMessage.value}'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report e Grafici'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        actions: [
          IconButton(icon: const Icon(Icons.ios_share, color: adminPrimaryColor), onPressed: _handleExport, tooltip: 'Esporta Report'),
          IconButton(icon: const Icon(Icons.refresh, color: adminPrimaryColor), onPressed: _controller.loadData, tooltip: 'Aggiorna Dati'),
        ],
      ),
      body: ValueListenableBuilder<DashboardState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          if (state == DashboardState.loading) {
            return const Center(child: CircularProgressIndicator(color: adminPrimaryColor));
          }
          if (state == DashboardState.error) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Errore durante il caricamento dei dati:\n${_controller.errorMessage.value}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            ));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTimeFilter(),
                const SizedBox(height: 32),
                ValueListenableBuilder<Map<String, dynamic>>(
                  valueListenable: _controller.chartData,
                  builder: (context, data, _) {
                    final conferimenti = data['conferimenti'] as List? ?? [];
                    final segnalazioni = data['segnalazioni'] as List? ?? [];
                    if (conferimenti.isEmpty && segnalazioni.isEmpty) {
                      return const Center(heightFactor: 10, child: Text("Nessun dato da visualizzare."));
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildChartCard(title: 'Segnalazioni Approvate per Livello', chart: _buildSegnalazioniBarChart(segnalazioni)),
                        const SizedBox(height: 24),
                        _buildChartCard(title: 'CO₂ Risparmiata (kg) per Giorno', chart: _buildCo2BarChart(conferimenti)),
                        const SizedBox(height: 24),
                        _buildChartCard(title: 'Andamento Punti Conferimenti', chart: _buildPuntiLineChart(conferimenti, adminAccentColor)),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeFilter() {
    return ValueListenableBuilder<StatsTimeRange>(
        valueListenable: _controller.timeRange,
        builder: (context, currentRange, _) {
          return SegmentedButton<StatsTimeRange>(
            style: SegmentedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: adminPrimaryColor, selectedForegroundColor: Colors.white, selectedBackgroundColor: adminPrimaryColor),
            segments: const [ButtonSegment(value: StatsTimeRange.month, label: Text('Mese')), ButtonSegment(value: StatsTimeRange.year, label: Text('Anno')), ButtonSegment(value: StatsTimeRange.allTime, label: Text('Sempre'))],
            selected: {currentRange},
            onSelectionChanged: (newSelection) => _controller.setTimeRange(newSelection.first),
          );
        });
  }

  Widget _buildChartCard({required String title, required Widget chart}) {
    return Card(
      elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 24), SizedBox(height: 220, child: chart)],
        ),
      ),
    );
  }

  Widget _buildSegnalazioniBarChart(List data) {
    final Map<String, int> aggregatedData = {'Basso': 0, 'Medio': 0, 'Alto': 0};
    for (var item in data) {
      if (item is Map && item['accettata'] == true && item['livelloinquinamento'] != null) {
        final level = item['livelloinquinamento'] as String;
        aggregatedData.update(level, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    if (aggregatedData.values.every((v) => v == 0)) return const Center(child: Text('Nessuna segnalazione approvata.'));
    final barGroups = aggregatedData.entries.map((entry) {
      final index = aggregatedData.keys.toList().indexOf(entry.key);
      return BarChartGroupData(x: index, barRods: [BarChartRodData(toY: entry.value.toDouble(), color: _getColorForLevel(entry.key), width: 35, borderRadius: BorderRadius.circular(4))]);
    }).toList();
    return BarChart(BarChartData(barGroups: barGroups, titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => SideTitleWidget(axisSide: meta.axisSide, child: Text(aggregatedData.keys.toList()[value.toInt()], style: const TextStyle(fontSize: 12))), reservedSize: 20)), leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))), borderData: FlBorderData(show: false), gridData: const FlGridData(show: false)));
  }

  Widget _buildCo2BarChart(List data) {
    if (data.isEmpty) return const Center(child: Text('Nessun dato sulla CO₂.'));
    final Map<DateTime, double> aggregatedData = {};
    for (var item in data) {
      if (item is Map && item['data_conferimento'] != null && item['peso_co2_totale'] != null) {
        final date = DateTime.parse(item['data_conferimento']);
        final day = DateTime(date.year, date.month, date.day);
        final value = (item['peso_co2_totale'] as num? ?? 0).toDouble();
        aggregatedData.update(day, (existing) => existing + value, ifAbsent: () => value);
      }
    }
    if (aggregatedData.isEmpty) return const Center(child: Text('Nessun dato valido sulla CO₂.'));
    final sortedEntries = aggregatedData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final barGroups = sortedEntries.asMap().entries.map((entry) => BarChartGroupData(x: entry.key, barRods: [BarChartRodData(toY: entry.value.value, color: adminPrimaryColor, width: 16, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))])).toList();
    return BarChart(BarChartData(barGroups: barGroups, titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
          if (value.toInt() >= sortedEntries.length) return const SizedBox.shrink();
          final date = sortedEntries[value.toInt()].key;
          return SideTitleWidget(axisSide: meta.axisSide, child: Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontSize: 10)));
        }, reservedSize: 20, interval: (sortedEntries.length / 7).ceil().toDouble())), leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))), borderData: FlBorderData(show: false), gridData: FlGridData(show: true, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 0.5))));
  }

  Widget _buildPuntiLineChart(List data, Color color) {
    if (data.isEmpty) return const Center(child: Text('Nessun dato disponibile'));
    final Map<DateTime, double> aggregatedData = {};
    for (var item in data) {
      if (item is Map && item['data_conferimento'] != null) {
        final date = DateTime.parse(item['data_conferimento']);
        final day = DateTime(date.year, date.month, date.day);
        final value = (item['punti_guadagnati'] as num? ?? 0).toDouble();
        aggregatedData.update(day, (existing) => existing + value, ifAbsent: () => value);
      }
    }
    if (aggregatedData.isEmpty) return const Center(child: Text('Nessun dato valido.'));
    final sortedEntries = aggregatedData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final spots = sortedEntries.map((entry) => FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value)).toList();
    double minX = spots.first.x; double maxX = spots.last.x;
    if (spots.length == 1) { minX = minX - const Duration(days: 1).inMilliseconds; maxX = maxX + const Duration(days: 1).inMilliseconds; }
    return LineChart(LineChartData(minX: minX, maxX: maxX, lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: color, barWidth: 3, dotData: const FlDotData(show: true), belowBarData: BarAreaData(show: true, color: color.withOpacity(0.2)))], titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (double v, TitleMeta m) => _bottomTitleWidgets(v, m, sortedEntries), interval: _calculateInterval(sortedEntries))), leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))), gridData: FlGridData(show: true, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 0.5)), borderData: FlBorderData(show: false)));
  }

  double _calculateInterval(List<MapEntry<DateTime, double>> entries) {
    if (entries.length < 2) return const Duration(days: 1).inMilliseconds.toDouble();
    final first = entries.first.key.millisecondsSinceEpoch;
    final last = entries.last.key.millisecondsSinceEpoch;
    final range = last - first;
    return range > 0 ? range / (entries.length > 7 ? 7 : entries.length) : const Duration(days: 1).inMilliseconds.toDouble();
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta, List<MapEntry<DateTime, double>> entries) {
    if (value > meta.max || value < meta.min) return const SizedBox.shrink();
    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return SideTitleWidget(axisSide: meta.axisSide, space: 8, child: Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontSize: 10)));
  }

  Color _getColorForLevel(String level) {
    switch (level.toLowerCase()) {
      case 'basso': return Colors.green;
      case 'medio': return Colors.orange;
      case 'alto': return Colors.red;
      default: return Colors.grey;
    }
  }
}

import 'package:cityclean/controllers/admin/dashboard_controller.dart';
import 'package:cityclean/screens/admin/admin_detailed_report_page.dart';
import 'package:cityclean/services/admin/dashboard_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color adminPrimaryColor = Color(0xFF2E7D32);
const Color adminAccentColor = Color(0xFF66BB6A);

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  AdminReportsPageState createState() => AdminReportsPageState();
}

class AdminReportsPageState extends State<AdminReportsPage> {
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

  Future<void> exportReport() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Preparazione del report...')));
    final success = await _controller.exportReport();
    scaffoldMessenger.removeCurrentSnackBar();
    if (!success) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Errore: ${_controller.errorMessage.value}'), backgroundColor: Colors.red));
    }
  }

  void refreshData() {
    _controller.loadData();
  }

  void _navigateToDetail(String title, List<dynamic> data) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDetailedReportPage(title: title, data: data)));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DashboardState>(
      valueListenable: _controller.state,
      builder: (context, state, _) {
        if (state == DashboardState.loading) {
          return const Center(child: CircularProgressIndicator(color: adminPrimaryColor));
        }
        if (state == DashboardState.error) {
          return Center(child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Errore:\n${_controller.errorMessage.value}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
          ));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTimeFilter(),
              const SizedBox(height: 24),
              ValueListenableBuilder<Map<String, dynamic>>(
                valueListenable: _controller.chartData,
                builder: (context, data, _) {
                  final conferimenti = data['conferimenti'] as List? ?? [];
                  final segnalazioni = data['segnalazioni'] as List? ?? [];
                  if (conferimenti.isEmpty && segnalazioni.isEmpty) {
                    return const Center(heightFactor: 10, child: Text("Nessun dato da visualizzare."));
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isWideScreen = constraints.maxWidth > 700;
                      final children = [
                        _buildChartCard(title: 'Segnalazioni Approvate per Livello', chart: _buildSegnalazioniBarChart(segnalazioni), onTap: () => _navigateToDetail('Dettaglio Segnalazioni', segnalazioni)),
                        _buildChartCard(title: 'CO₂ Risparmiata (kg)', chart: _buildCo2BarChart(conferimenti), onTap: () => _navigateToDetail('Dettaglio Conferimenti', conferimenti)),
                        _buildChartCard(title: 'Andamento Punti Conferimenti', chart: _buildPuntiLineChart(conferimenti, adminAccentColor), onTap: () => _navigateToDetail('Dettaglio Conferimenti', conferimenti)),
                      ];

                      if (isWideScreen) {
                        return GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          childAspectRatio: 1.2,
                          physics: const NeverScrollableScrollPhysics(),
                          children: children,
                        );
                      } else {
                        return Column(
                          children: children.map((card) => Padding(padding: const EdgeInsets.only(bottom: 16.0), child: card)).toList(),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
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

  Widget _buildChartCard({required String title, required Widget chart, required VoidCallback onTap}) {
    return SizedBox(
      height: 300,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(child: chart),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Funzione helper per le etichette dell'asse Y (sinistro)
  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    if (value == meta.max) return Container(); // Nasconde l'etichetta superiore per evitare sovrapposizioni
    final compactNumber = NumberFormat.compact().format(value);
    return SideTitleWidget(axisSide: meta.axisSide, space: 8, child: Text(compactNumber, style: const TextStyle(fontSize: 10)));
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
      return BarChartGroupData(
        x: index,
        barRods: [BarChartRodData(toY: entry.value.toDouble(), color: _getColorForLevel(entry.key), width: 25, borderRadius: BorderRadius.circular(4))],
      );
    }).toList();

    final double maxY = aggregatedData.values.isEmpty ? 0 : aggregatedData.values.reduce((a, b) => a > b ? a : b).toDouble();
    final double leftInterval = (maxY > 5) ? (maxY / 5).ceil().toDouble() : 1;
    final double chartMaxY = (leftInterval > 1) ? leftInterval * 5 : 5;

    return BarChart(BarChartData(
        maxY: chartMaxY,
        barGroups: barGroups,
        titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => SideTitleWidget(axisSide: meta.axisSide, child: Text(aggregatedData.keys.toList()[value.toInt()], style: const TextStyle(fontSize: 11))), reservedSize: 22)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: leftInterval, getTitlesWidget: _leftTitleWidgets)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
        borderData: FlBorderData(show: true, border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: leftInterval, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
        barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData(getTooltipColor: (_) => Colors.blueGrey))));
  }

  Widget _buildCo2BarChart(List data) {
    if (data.isEmpty) return const Center(child: Text('Nessun dato sulla CO₂.'));

    final now = DateTime.now();
    Map<double, double> totals = {};
    String Function(double) getTitle;

    switch (_controller.timeRange.value) {
      case StatsTimeRange.month:
        totals = {for (var i = 0; i < 30; i++) i.toDouble(): 0.0};
        for (var item in data) {
          if (item['data_conferimento'] != null) {
            final date = DateTime.parse(item['data_conferimento']);
            final diff = now.difference(date).inDays;
            if (diff >= 0 && diff < 30) {
              totals.update((29 - diff).toDouble(), (value) => value + (item['peso_co2_totale'] as num).toDouble());
            }
          }
        }
        getTitle = (value) {
          final day = now.subtract(Duration(days: 29 - value.toInt()));
          return DateFormat('d').format(day);
        };
        break;
      case StatsTimeRange.year:
        totals = {for (var i = 0; i < 12; i++) i.toDouble(): 0.0};
        for (var item in data) {
          if (item['data_conferimento'] != null) {
            final date = DateTime.parse(item['data_conferimento']);
            if (date.year == now.year) {
              totals.update((date.month - 1).toDouble(), (value) => value + (item['peso_co2_totale'] as num).toDouble());
            }
          }
        }
        getTitle = (value) => DateFormat.MMM('it').format(DateTime(now.year, value.toInt() + 1));
        break;
      case StatsTimeRange.allTime:
        Map<int, double> yearlyTotals = {};
        for (var item in data) {
          if (item['data_conferimento'] != null) {
            final date = DateTime.parse(item['data_conferimento']);
            yearlyTotals.update(date.year, (value) => value + (item['peso_co2_totale'] as num).toDouble(), ifAbsent: () => (item['peso_co2_totale'] as num).toDouble());
          }
        }
        var years = yearlyTotals.keys.toList()..sort();
        totals = {for (var i = 0; i < years.length; i++) i.toDouble(): yearlyTotals[years[i]]!};
        getTitle = (value) => years[value.toInt()].toString();
        break;
    }

    if (totals.values.every((v) => v == 0)) return const Center(child: Text('Nessun dato valido sulla CO₂.'));

    final barGroups = totals.entries.map((entry) => BarChartGroupData(x: entry.key.toInt(), barRods: [BarChartRodData(toY: entry.value, color: adminPrimaryColor, width: 16, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))])).toList();

    final double maxY = totals.values.isEmpty ? 0 : totals.values.reduce((a, b) => a > b ? a : b);
    final double leftInterval = (maxY > 5) ? (maxY / 5).ceil().toDouble() : 1;
    final double chartMaxY = (leftInterval > 1) ? leftInterval * 5 : 5;

    return BarChart(BarChartData(
        maxY: chartMaxY,
        barGroups: barGroups,
        titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, meta) => _bottomTitleWidgets(value, meta, totals, getTitle))), 
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: leftInterval, getTitlesWidget: _leftTitleWidgets)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
        borderData: FlBorderData(show: true, border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: leftInterval, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
        barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData(getTooltipColor: (_) => Colors.blueGrey))));
  }

  Widget _buildPuntiLineChart(List data, Color color) {
    if (data.isEmpty) return const Center(child: Text('Nessun dato disponibile'));

    final now = DateTime.now();
    Map<double, double> totals = {};
    String Function(double) getTitle;

    switch (_controller.timeRange.value) {
      case StatsTimeRange.month:
        totals = {for (var i = 0; i < 30; i++) i.toDouble(): 0.0};
        for (var item in data) {
          if (item['data_conferimento'] != null) {
            final date = DateTime.parse(item['data_conferimento']);
            final diff = now.difference(date).inDays;
            if (diff >= 0 && diff < 30) {
              totals.update((29 - diff).toDouble(), (value) => value + (item['punti_guadagnati'] as num).toDouble());
            }
          }
        }
        getTitle = (value) {
          final day = now.subtract(Duration(days: 29 - value.toInt()));
          return DateFormat('d').format(day);
        };
        break;
      case StatsTimeRange.year:
        totals = {for (var i = 0; i < 12; i++) i.toDouble(): 0.0};
        for (var item in data) {
          if (item['data_conferimento'] != null) {
            final date = DateTime.parse(item['data_conferimento']);
            if (date.year == now.year) {
              totals.update((date.month - 1).toDouble(), (value) => value + (item['punti_guadagnati'] as num).toDouble());
            }
          }
        }
        getTitle = (value) => DateFormat.MMM('it').format(DateTime(now.year, value.toInt() + 1));
        break;
      case StatsTimeRange.allTime:
        Map<int, double> yearlyTotals = {};
        for (var item in data) {
          if (item['data_conferimento'] != null) {
            final date = DateTime.parse(item['data_conferimento']);
            yearlyTotals.update(date.year, (value) => value + (item['punti_guadagnati'] as num).toDouble(), ifAbsent: () => (item['punti_guadagnati'] as num).toDouble());
          }
        }
        var years = yearlyTotals.keys.toList()..sort();
        totals = {for (var i = 0; i < years.length; i++) i.toDouble(): yearlyTotals[years[i]]!};
        getTitle = (value) => years[value.toInt()].toString();
        break;
    }

    if (totals.values.every((v) => v == 0)) return const Center(child: Text('Nessun dato valido.'));

    final spots = totals.entries.map((e) => FlSpot(e.key, e.value)).toList();

    final double maxY = totals.values.isEmpty ? 0 : totals.values.reduce((a, b) => a > b ? a : b);
    final double leftInterval = (maxY > 5) ? (maxY / 5).ceil().toDouble() : 1;
    final double chartMaxY = (leftInterval > 1) ? leftInterval * 5 : 5;

    return LineChart(LineChartData(
        maxY: chartMaxY,
        lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: color, barWidth: 3, dotData: const FlDotData(show: true), belowBarData: BarAreaData(show: true, color: color.withOpacity(0.2)))],
        titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, meta) => _bottomTitleWidgets(value, meta, totals, getTitle))),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: leftInterval, getTitlesWidget: _leftTitleWidgets)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: leftInterval, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
        borderData: FlBorderData(show: true, border: Border(bottom: BorderSide(color: Colors.grey.shade300)))));
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta, Map<double, double> totals, String Function(double) getTitle) {
    final int index = value.toInt();
    String text = '';
    final timeRange = _controller.timeRange.value;
    switch (timeRange) {
      case StatsTimeRange.month:
        if (index % 5 == 0 || index == 29) text = getTitle(value);
        break;
      case StatsTimeRange.year:
        if (index % 2 == 0) text = getTitle(value);
        break;
      case StatsTimeRange.allTime:
        final count = totals.length;
        if (count <= 8 || index == 0 || index == count - 1 || index % ((count / 4).round()) == 0) {
          text = getTitle(value);
        }
        break;
    }
    return SideTitleWidget(axisSide: meta.axisSide, space: 8, child: Text(text, style: const TextStyle(fontSize: 10)));
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

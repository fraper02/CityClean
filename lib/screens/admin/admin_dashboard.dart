import 'package:cityclean/controllers/admin/dashboard_controller.dart';
import 'package:cityclean/screens/admin/admin_events_page.dart';
import 'package:cityclean/screens/admin/admin_list_ecopoints_page.dart';
import 'package:cityclean/screens/admin/admin_reports_page.dart';
import 'package:cityclean/screens/admin/admin_rewards_page.dart';
import 'package:cityclean/screens/admin/admin_segnalazioni_page.dart';
import 'package:cityclean/screens/admin/admin_users_page.dart';
import 'package:cityclean/screens/admin/admin_waste_values_page.dart';
import 'package:cityclean/services/admin/dashboard_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color adminPrimaryColor = Color(0xFF2E7D32);
const Color adminAccentColor = Color(0xFF66BB6A);

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _adminPages;

  @override
  void initState() {
    super.initState();
    _adminPages = <Widget>[
      AdminDashboardView(onNavigate: _onItemTapped),
      const AdminReportsPage(),
      const AdminSegnalazioniPage(),
      const AdminEventsPage(), // <-- PAGINA INSERITA
      const AdminListEcopointsPage(),
      const AdminUsersPage(),
      const AdminRewardsPage(),
      const AdminWasteValuesPage(),
    ];
  }

  void _onItemTapped(int index) {
    if (index < _adminPages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: _onItemTapped,
                      labelType: NavigationRailLabelType.all,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      indicatorColor: adminAccentColor.withOpacity(0.2),
                      unselectedIconTheme: IconThemeData(color: Colors.grey[600]),
                      selectedIconTheme: const IconThemeData(color: adminPrimaryColor),
                      destinations: const <NavigationRailDestination>[
                        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
                        NavigationRailDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: Text('Report')),
                        NavigationRailDestination(icon: Icon(Icons.report_problem_outlined), selectedIcon: Icon(Icons.report_problem), label: Text('Segnalazioni')),
                        NavigationRailDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: Text('Eventi')),
                        NavigationRailDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on), label: Text('Ecopunti')),
                        NavigationRailDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: Text('Utenti')),
                        NavigationRailDestination(icon: Icon(Icons.card_giftcard_outlined), selectedIcon: Icon(Icons.card_giftcard), label: Text('Premi')),
                        NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Valori Rifiuto')),
                      ],
                    ),
                  ),
                ),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: _adminPages[_selectedIndex]),
            ],
          );
        },
      ),
    );
  }
}

// Le altre classi della dashboard non vengono modificate...

class AdminDashboardView extends StatefulWidget {
  final Function(int) onNavigate;

  const AdminDashboardView({super.key, required this.onNavigate});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panoramica Generale'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        actions: [IconButton(icon: const Icon(Icons.refresh, color: adminPrimaryColor), onPressed: _controller.loadData, tooltip: 'Aggiorna Statistiche')],
      ),
      body: ValueListenableBuilder<DashboardState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          if (state == DashboardState.loading) {
            return const Center(child: CircularProgressIndicator(color: adminPrimaryColor));
          }
          if (state == DashboardState.error) {
            return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Errore: ${_controller.errorMessage.value}', style: const TextStyle(color: Colors.red))));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTimeFilter(),
                const SizedBox(height: 24),
                ValueListenableBuilder(
                  valueListenable: _controller.stats,
                  builder: (context, stats, _) {
                    return LayoutBuilder(builder: (context, constraints) {
                      final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
                      final aspectRatio = _calculateAspectRatio(crossAxisCount, constraints.maxWidth);

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        childAspectRatio: aspectRatio,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStatCard('Utenti Totali', stats.totalUsers, Icons.people, Colors.blue, crossAxisCount, onTap: () => widget.onNavigate(5)), // Indice aggiornato
                          _buildStatCard('Conferimenti', stats.totalConferimenti, Icons.recycling, adminPrimaryColor, crossAxisCount, onTap: () => widget.onNavigate(1)),
                          _buildStatCard('CO₂ Risparmiata (kg)', stats.totalCo2.toInt(), Icons.eco, Colors.teal, crossAxisCount, onTap: () => widget.onNavigate(1)),
                          _buildStatCard('Segnalazioni', stats.totalSegnalazioni, Icons.report, Colors.orange, crossAxisCount, onTap: () => widget.onNavigate(2)),
                          _buildStatCard('Eventi', stats.totalMissioniCompletate, Icons.event, Colors.purple, crossAxisCount, onTap: () => widget.onNavigate(3)), // Indice aggiornato
                          _buildStatCard('Premi', stats.puntiSpesi, Icons.shopping_cart, Colors.red, crossAxisCount, onTap: () => widget.onNavigate(6)), // Indice aggiornato
                        ],
                      );
                    });
                  },
                ),
                const SizedBox(height: 32),
                ValueListenableBuilder<Map<String, dynamic>>(
                  valueListenable: _controller.chartData,
                  builder: (context, data, child) {
                    return _buildChartCard(
                        title: 'Conferimenti Ultimi 7 Giorni',
                        chart: _buildBarChart((data['conferimenti'] as List? ?? []), adminAccentColor));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _calculateCrossAxisCount(double width) {
    if (width > 1200) return 3;
    if (width > 700) return 2;
    return 1;
  }

  double _calculateAspectRatio(int crossAxisCount, double width) {
    if (crossAxisCount == 1) {
      return width / 80;
    }
    return 1.4;
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
      },
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color, int crossAxisCount, {VoidCallback? onTap}) {
    final formattedValue = NumberFormat.compact().format(value);

    if (crossAxisCount == 1) {
      return Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(width: 16),
                Expanded(child: Text(title, style: TextStyle(color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.w500))),
                Text(formattedValue, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(child: Text(title, style: TextStyle(color: Colors.grey[800], fontSize: 15, fontWeight: FontWeight.w500))),
                  Icon(icon, size: 24, color: color),
                ],
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(formattedValue, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard({required String title, required Widget chart}) {
    return Card(
      elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBarChart(List conferimenti, Color color) {
    if (conferimenti.isEmpty) return const Center(child: Text("Nessun conferimento recente."));

    final Map<int, double> dailyTotals = { for (var i = 0; i < 7; i++) i: 0.0 };
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var item in conferimenti) {
      if (item['data_conferimento'] != null) {
        final date = DateTime.parse(item['data_conferimento']);
        final day = DateTime(date.year, date.month, date.day);
        final diff = today.difference(day).inDays;

        if (diff >= 0 && diff < 7) {
          dailyTotals.update(6 - diff, (value) => value + 1, ifAbsent: () => 1);
        }
      }
    }

    final barGroups = dailyTotals.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [BarChartRodData(toY: entry.value, color: color, width: 22, borderRadius: BorderRadius.circular(4))],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
            final day = today.subtract(Duration(days: 6 - value.toInt()));
            return SideTitleWidget(axisSide: meta.axisSide, child: Text(DateFormat('E').format(day), style: const TextStyle(fontSize: 10)));
          }, reservedSize: 20)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
      ),
    );
  }
}

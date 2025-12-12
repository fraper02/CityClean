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
  late final DashboardController _dashboardController;

  final _dashboardKey = GlobalKey<AdminDashboardViewState>();
  final _reportsKey = GlobalKey<AdminReportsPageState>();
  final _segnalazioniKey = GlobalKey<AdminSegnalazioniPageState>();
  final _eventsKey = GlobalKey<AdminEventsPageState>();
  final _ecopointsKey = GlobalKey<AdminListEcopointsPageState>();
  final _usersKey = GlobalKey<AdminUsersPageState>();
  final _rewardsKey = GlobalKey<AdminRewardsPageState>();
  final _wasteValuesKey = GlobalKey<AdminWasteValuesPageState>();

  late final List<GlobalKey> _pageKeys;

  static const List<String> _pageTitles = [
    'Panoramica Generale',
    'Report',
    'Segnalazioni',
    'Eventi',
    'Ecopunti',
    'Utenti',
    'Premi',
    'Valori Rifiuto',
  ];

  @override
  void initState() {
    super.initState();
    _dashboardController = DashboardController();
    _pageKeys = [_dashboardKey, _reportsKey, _segnalazioniKey, _eventsKey, _ecopointsKey, _usersKey, _rewardsKey, _wasteValuesKey];
    _adminPages = <Widget>[
      AdminDashboardView(
        key: _dashboardKey,
        controller: _dashboardController,
        onNavigate: _onItemTapped,
      ),
      AdminReportsPage(key: _reportsKey),
      AdminSegnalazioniPage(key: _segnalazioniKey),
      AdminEventsPage(key: _eventsKey),
      AdminListEcopointsPage(key: _ecopointsKey),
      AdminUsersPage(key: _usersKey),
      AdminRewardsPage(key: _rewardsKey),
      AdminWasteValuesPage(key: _wasteValuesKey),
    ];
  }

  @override
  void dispose() {
    _dashboardController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index < _adminPages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  List<Widget> _buildAppBarActions() {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return [IconButton(icon: const Icon(Icons.refresh, color: adminPrimaryColor), onPressed: () => _dashboardController.loadData(), tooltip: 'Aggiorna Statistiche')];
      case 1: // Reports
        return [
          IconButton(icon: const Icon(Icons.ios_share, color: adminPrimaryColor), onPressed: () => _reportsKey.currentState?.exportReport(), tooltip: 'Esporta Report'),
          IconButton(icon: const Icon(Icons.refresh, color: adminPrimaryColor), onPressed: () => _reportsKey.currentState?.refreshData(), tooltip: 'Aggiorna Dati'),
        ];
      case 2: // Segnalazioni
        return [IconButton(icon: const Icon(Icons.refresh, color: adminPrimaryColor), onPressed: () => _segnalazioniKey.currentState?.refreshSegnalazioni(), tooltip: 'Aggiorna Segnalazioni')];
      case 3: // Eventi
        return [
          IconButton(icon: const Icon(Icons.add, color: adminPrimaryColor), onPressed: () => _eventsKey.currentState?.createNewEvent(), tooltip: 'Crea Evento'),
          IconButton(icon: const Icon(Icons.refresh, color: adminPrimaryColor), onPressed: () => _eventsKey.currentState?.refreshEvents(), tooltip: 'Aggiorna Eventi'),
        ];
       case 4: // Ecopunti
        return [IconButton(icon: const Icon(Icons.refresh, color: adminPrimaryColor), onPressed: () => _ecopointsKey.currentState?.refreshEcopoints(), tooltip: 'Aggiorna Ecopunti')];
      case 5: // Utenti
         return [IconButton(icon: const Icon(Icons.refresh, color: adminPrimaryColor), onPressed: () => _usersKey.currentState?.refreshUsers(), tooltip: 'Aggiorna Utenti')];
      case 6: // Premi
        return [IconButton(icon: const Icon(Icons.refresh, color: adminPrimaryColor), onPressed: () => _rewardsKey.currentState?.refreshRewards(), tooltip: 'Aggiorna Premi')];
      case 7: // Valori Rifiuto
        return [IconButton(icon: const Icon(Icons.refresh, color: adminPrimaryColor), onPressed: () => _wasteValuesKey.currentState?.refreshWasteValues(), tooltip: 'Aggiorna Valori')];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 800;

    final adminMenu = AdminMenu(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        _onItemTapped(index);
        if (!isWideScreen) {
          Navigator.pop(context);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        actions: _buildAppBarActions(),
      ),
      drawer: isWideScreen ? null : Drawer(child: adminMenu),
      body: Row(
        children: [
          if (isWideScreen) adminMenu,
          Expanded(child: _adminPages[_selectedIndex]),
        ],
      ),
    );
  }
}

class AdminMenu extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AdminMenu({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  static const _destinations = [
    {'icon': Icons.dashboard_outlined, 'selectedIcon': Icons.dashboard, 'label': 'Dashboard'},
    {'icon': Icons.bar_chart_outlined, 'selectedIcon': Icons.bar_chart, 'label': 'Report'},
    {'icon': Icons.report_problem_outlined, 'selectedIcon': Icons.report_problem, 'label': 'Segnalazioni'},
    {'icon': Icons.event_outlined, 'selectedIcon': Icons.event, 'label': 'Eventi'},
    {'icon': Icons.location_on_outlined, 'selectedIcon': Icons.location_on, 'label': 'Ecopunti'},
    {'icon': Icons.people_outline, 'selectedIcon': Icons.people, 'label': 'Utenti'},
    {'icon': Icons.card_giftcard_outlined, 'selectedIcon': Icons.card_giftcard, 'label': 'Premi'},
    {'icon': Icons.settings_outlined, 'selectedIcon': Icons.settings, 'label': 'Valori Rifiuto'},
  ];

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    final theme = Theme.of(context);

    final menuItems = ListView(
      padding: EdgeInsets.zero,
      children: [
        if (isWideScreen)
           SizedBox(
            height: 80,
            child: Center(
              child: Text(
                'CityClean Admin',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          )
        else
          DrawerHeader(
            decoration: const BoxDecoration(color: adminPrimaryColor),
            child: Text(
              'CityClean Admin',
              style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
          ),
        for (int i = 0; i < _destinations.length; i++)
          ListTile(
            leading: Icon(selectedIndex == i ? _destinations[i]['selectedIcon'] as IconData : _destinations[i]['icon'] as IconData),
            title: Text(_destinations[i]['label'] as String),
            selected: selectedIndex == i,
            onTap: () => onDestinationSelected(i),
            selectedTileColor: adminPrimaryColor.withOpacity(0.1),
            selectedColor: adminPrimaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          ),
      ],
    );

    if (isWideScreen) {
      return Material(
        elevation: 2,
        color: theme.colorScheme.surface,
        child: SizedBox(
          width: 250,
          child: menuItems,
        ),
      );
    }
    return menuItems;
  }
}


class AdminDashboardView extends StatefulWidget {
  final DashboardController controller;
  final Function(int) onNavigate;

  const AdminDashboardView({
    super.key,
    required this.controller,
    required this.onNavigate,
  });

  @override
  State<AdminDashboardView> createState() => AdminDashboardViewState();
}

class AdminDashboardViewState extends State<AdminDashboardView> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.state.value == DashboardState.initial) {
      widget.controller.loadData();
    }
  }

  String get _chartTitle {
    switch (widget.controller.timeRange.value) {
      case StatsTimeRange.month:
        return 'Conferimenti Ultimo Mese';
      case StatsTimeRange.year:
        return 'Conferimenti Ultimo Anno';
      case StatsTimeRange.allTime:
        return 'Conferimenti Totali';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DashboardState>(
      valueListenable: widget.controller.state,
      builder: (context, state, _) {
        if (state == DashboardState.loading) {
          return const Center(child: CircularProgressIndicator(color: adminPrimaryColor));
        }
        if (state == DashboardState.error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Errore: ${widget.controller.errorMessage.value}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTimeFilter(),
              const SizedBox(height: 24),
              ValueListenableBuilder(
                valueListenable: widget.controller.stats,
                builder: (context, stats, _) {
                  return LayoutBuilder(builder: (context, constraints) {
                    final crossAxisCount = (constraints.maxWidth > 1200) ? 3 : 2;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      childAspectRatio: (constraints.maxWidth > 600) ? 1.2 : 0.9,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StatCard(title: 'Utenti Totali', value: stats.totalUsers, icon: Icons.people, color: Colors.blue, onTap: () => widget.onNavigate(5)),
                        StatCard(title: 'Conferimenti', value: stats.totalConferimenti, icon: Icons.recycling, color: adminPrimaryColor, onTap: () => widget.onNavigate(1)),
                        StatCard(title: 'CO₂ Risparmiata (kg)', value: stats.totalCo2.toInt(), icon: Icons.eco, color: Colors.teal, onTap: () => widget.onNavigate(1)),
                        StatCard(title: 'Segnalazioni', value: stats.totalSegnalazioni, icon: Icons.report, color: Colors.orange, onTap: () => widget.onNavigate(2)),
                        StatCard(title: 'Eventi', value: stats.totalMissioniCompletate, icon: Icons.event, color: Colors.purple, onTap: () => widget.onNavigate(3)),
                        StatCard(title: 'Premi Riscattati', value: stats.puntiSpesi, icon: Icons.shopping_cart, color: Colors.red, onTap: () => widget.onNavigate(6)),
                      ],
                    );
                  });
                },
              ),
              const SizedBox(height: 32),
              ValueListenableBuilder<Map<String, dynamic>>(
                valueListenable: widget.controller.chartData,
                builder: (context, data, child) {
                  return _buildChartCard(
                    title: _chartTitle,
                    chart: _buildBarChart(
                      (data['conferimenti'] as List? ?? []),
                      adminAccentColor,
                      widget.controller.timeRange.value,
                    ),
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
      valueListenable: widget.controller.timeRange,
      builder: (context, currentRange, _) {
        return SegmentedButton<StatsTimeRange>(
          style: SegmentedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: adminPrimaryColor,
            selectedForegroundColor: Colors.white,
            selectedBackgroundColor: adminPrimaryColor,
          ),
          segments: const [
            ButtonSegment(value: StatsTimeRange.month, label: Text('Mese')),
            ButtonSegment(value: StatsTimeRange.year, label: Text('Anno')),
            ButtonSegment(value: StatsTimeRange.allTime, label: Text('Sempre')),
          ],
          selected: {currentRange},
          onSelectionChanged: (newSelection) => widget.controller.setTimeRange(newSelection.first),
        );
      },
    );
  }

  Widget _buildChartCard({required String title, required Widget chart}) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  Widget _buildBarChart(List conferimenti, Color color, StatsTimeRange timeRange) {
    if (conferimenti.isEmpty) {
      return const Center(child: Text("Nessun conferimento nel periodo selezionato."));
    }

    final now = DateTime.now();
    Map<double, double> totals = {};
    String Function(double) getTitle;

    switch (timeRange) {
      case StatsTimeRange.month:
        totals = {for (var i = 0; i < 30; i++) i.toDouble(): 0.0};
        for (var item in conferimenti) {
          if (item['data_conferimento'] != null) {
            final date = DateTime.parse(item['data_conferimento']);
            final diff = now.difference(date).inDays;
            if (diff >= 0 && diff < 30) {
              totals.update((29 - diff).toDouble(), (value) => value + 1);
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
        for (var item in conferimenti) {
          if (item['data_conferimento'] != null) {
            final date = DateTime.parse(item['data_conferimento']);
            if (date.year == now.year) {
              totals.update((date.month - 1).toDouble(), (value) => value + 1);
            }
          }
        }
        getTitle = (value) => DateFormat.MMM('it').format(DateTime(now.year, value.toInt() + 1));
        break;
      case StatsTimeRange.allTime:
        Map<int, double> yearlyTotals = {};
        for (var item in conferimenti) {
          if (item['data_conferimento'] != null) {
            final date = DateTime.parse(item['data_conferimento']);
            yearlyTotals.update(date.year, (value) => value + 1, ifAbsent: () => 1.0);
          }
        }
        var years = yearlyTotals.keys.toList()..sort();
        totals = {for (var i = 0; i < years.length; i++) i.toDouble(): yearlyTotals[years[i]]!};
        getTitle = (value) => years[value.toInt()].toString();
        break;
    }

    final barGroups = totals.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key.toInt(),
        barRods: [BarChartRodData(toY: entry.value, color: color, width: 22, borderRadius: BorderRadius.circular(4))],
      );
    }).toList();

    final double maxY = totals.values.isEmpty ? 0 : totals.values.reduce((a, b) => a > b ? a : b);
    final double leftInterval = (maxY > 5) ? (maxY / 5).ceil().toDouble() : 1;
    final double chartMaxY = (leftInterval > 1) ? leftInterval * 5 : 5;

    return BarChart(
      BarChartData(
        maxY: chartMaxY,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                String text = '';
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
                return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: const TextStyle(fontSize: 10)));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: leftInterval,
              getTitlesWidget: (value, meta) {
                if (value == meta.max) return Container();
                final compactNumber = NumberFormat.compact().format(value);
                return SideTitleWidget(axisSide: meta.axisSide, space: 8, child: Text(compactNumber, style: const TextStyle(fontSize: 10)));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true, border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: leftInterval,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedValue = NumberFormat.compact().format(value);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(icon, size: 28, color: color),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formattedValue,
                style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, height: 1.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

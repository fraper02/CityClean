import 'package:cityclean/controllers/admin/dashboard_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'admin_list_ecopoints_page.dart';

// Placeholder per le sezioni non ancora implementate
class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Gestione Utenti')), body: const Center(child: Text('Pagina Gestione Utenti')));
}

class ManagePrizesScreen extends StatelessWidget {
  const ManagePrizesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Gestione Premi')), body: const Center(child: Text('Pagina Gestione Premi')));
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    _controller.loadDashboardData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DashboardState>(
      valueListenable: _controller.state,
      builder: (context, state, _) {
        if (state == DashboardState.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state == DashboardState.error) {
          return Center(child: Text(_controller.errorMessage.value));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Panoramica Generale", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _buildStatCard("Utenti Totali", _controller.totalUsers.value.toString(), Icons.people, Colors.blue),
                  _buildStatCard("Segnalazioni Aperte", _controller.openReports.value.toString(), Icons.report_problem, Colors.orange),
                  _buildStatCard("Premi Riscattati Oggi", "12", Icons.card_giftcard, Colors.green), // Esempio statico
                ],
              ),
              const SizedBox(height: 24),
              _buildChartCard(),
              const SizedBox(height: 24),
              const Text("Reportistica", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildReportCard(),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildReportCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Generazione report in corso...')),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              const Icon(Icons.description, color: Colors.purple, size: 32),
              const SizedBox(width: 16),
              const Expanded(
                child: Text("Genera Report Attività", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.download_for_offline, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 250),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(color: Colors.grey[700])),
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    return Card(
       elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Attività Settimanale (Conferimenti)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                // CORREZIONE DEFINITIVA
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: _getChartData(),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

    List<BarChartGroupData> _getChartData() {
    return [
      _makeGroupData(0, 5, Colors.blue),
      _makeGroupData(1, 6.5, Colors.blue),
      _makeGroupData(2, 5, Colors.blue),
      _makeGroupData(3, 7.5, Colors.green),
      _makeGroupData(4, 9, Colors.green),
      _makeGroupData(5, 11.5, Colors.green),
      _makeGroupData(6, 6.5, Colors.blue),
    ];
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  static final List<Widget> _adminPages = <Widget>[
    const DashboardView(),
    const AdminListEcopointsPage(),
    const ManageUsersScreen(),
    const ManagePrizesScreen(),
  ];

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
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.grey[200],
            indicatorColor: Colors.green[200],
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.location_on_outlined),
                selectedIcon: Icon(Icons.location_on),
                label: Text('Ecopunti'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Utenti'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.card_giftcard),
                selectedIcon: Icon(Icons.card_giftcard_sharp),
                label: Text('Premi'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _adminPages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

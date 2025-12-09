import 'package:cityclean/screens/admin/admin_waste_values_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_users_page.dart';
import 'admin_add_ecopoint_page.dart';
import 'admin_rewards_page.dart'; // <--- IMPORTA IL NUOVO FILE

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    // Lista Pagine
    final List<Widget> pages = [
      const _AdminHomePage(),         // 0. Home
      const AdminUsersPage(),         // 1. Utenti
      const AdminAddEcopointPage(),   // 2. Ecopoints
      const AdminRewardsPage(),       // 3. Premi
      const AdminWasteValuesPage()    // 4. Valori Rifiuti
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("CityClean Admin"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await supabase.auth.signOut();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Utenti'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add_location_alt),
                label: Text('Ecopoint'),
              ),
              // NUOVO TAB PREMI
              NavigationRailDestination(
                icon: Icon(Icons.card_giftcard),
                label: Text('Premi'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Valori Rifiuti'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}

// ... _AdminHomePage rimane invariato ...
class _AdminHomePage extends StatelessWidget {
  const _AdminHomePage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.admin_panel_settings, size: 80, color: Colors.green),
          const SizedBox(height: 20),
          const Text(
            "Benvenuto nel Pannello Admin",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text("Gestisci Utenti, Punti Raccolta e Premi dal menu a sinistra."),
        ],
      ),
    );
  }
}
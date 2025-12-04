import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';
import '../components/auth_gate.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  Future<void> _signOut() async {
    await StorageService.clearSession();
    await supabase.auth.signOut();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthGate()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Impostazioni",
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              "Gestisci le tue preferenze",
                              style: TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                  const Text("Preferenze", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.antiAlias, // Ritaglia l'effetto ripple
                    child: Column(
                      children: [
                        SwitchListTile(
                          activeColor: primaryGreen,
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                            child: Icon(Icons.notifications_outlined, color: primaryGreen),
                          ),
                          title: const Text("Notifiche", style: TextStyle(fontWeight: FontWeight.w500)),
                          value: _notificationsEnabled,
                          onChanged: (bool value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          },
                        ),
                        const Divider(height: 1, indent: 60, endIndent: 20),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                            child: Icon(Icons.language, color: primaryGreen),
                          ),
                          title: const Text("Lingua", style: TextStyle(fontWeight: FontWeight.w500)),
                          trailing: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Italiano", style: TextStyle(color: Colors.grey)),
                              Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text("Account", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.antiAlias, // Ritaglia l'effetto ripple
                    child: Column(
                      children: [
                        _buildListTile(Icons.lock_outline, "Privacy e Sicurezza", primaryGreen),
                        const Divider(height: 1, indent: 60, endIndent: 20),
                        _buildListTile(Icons.help_outline, "Aiuto e Supporto", primaryGreen),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: _signOut,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryGreen,
                        side: BorderSide(color: primaryGreen, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text("Esci", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}

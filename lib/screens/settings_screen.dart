import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../components/auth_gate.dart';
import '../main.dart';
import 'privacy_security_page.dart';
import 'help_support_page.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // WIP: Lo stato delle notifiche è solo visuale per ora
  final bool _notificationsEnabled = true;
  String _selectedLanguage = "Italiano";

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

  // Helper per mostrare WIP
  void _showWipMessage() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.construction, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text("Funzionalità in fase di sviluppo.")),
          ],
        ),
        backgroundColor: Colors.orange[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, Color primaryColor) {
    final List<String> languages = ["Italiano", "English"];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Seleziona Lingua", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              const SizedBox(height: 15),
              ...languages.map((lang) => ListTile(
                key: Key('lang_option_$lang'),
                leading: Icon(
                    lang == _selectedLanguage ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: lang == _selectedLanguage ? primaryColor : Colors.grey
                ),
                // MODIFICA QUI: Se è English, mostriamo il badge WIP
                title: Row(
                  children: [
                    Text(lang, style: const TextStyle(fontSize: 16)),
                    if (lang == "English") ...[
                      const SizedBox(width: 10),
                      _buildWipBadge(),
                    ]
                  ],
                ),
                onTap: () {
                  if (lang == "English") {
                    _showWipMessage(); // Mostra avviso se cliccano su English
                    Navigator.pop(context);
                    return;
                  }
                  setState(() => _selectedLanguage = lang);
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // -----------------------------------------------------------
          // 1. LIVELLO INFERIORE: IL CONTENUTO (SCROLLABLE)
          // -----------------------------------------------------------
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 140, left: 20, right: 20, bottom: 40),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // CARD 1: GENERALI
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        _buildSectionHeader("Generali"),
                        SwitchListTile(
                          key: const Key('switch_notifications'),
                          activeColor: primaryGreen,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.orange[50], shape: BoxShape.circle),
                            child: Icon(Icons.notifications_active_outlined, color: Colors.orange[700]),
                          ),
                          title: Row(
                            children: [
                              const Text("Notifiche Push", style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(width: 8),
                              _buildWipBadge(),
                            ],
                          ),
                          value: _notificationsEnabled,
                          onChanged: (bool value) => _showWipMessage(),
                        ),
                        const Divider(indent: 70),
                        _buildListTile(
                          key: const Key('btn_language'),
                          icon: Icons.language,
                          iconColor: Colors.blue[700]!,
                          iconBg: Colors.blue[50]!,
                          title: "Lingua",
                          trailingText: _selectedLanguage,
                          onTap: () => _showLanguageBottomSheet(context, primaryGreen),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CARD 2: SUPPORTO
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        _buildSectionHeader("Supporto e Info"),
                        _buildListTile(
                          key: const Key('btn_help'),
                          icon: Icons.help_outline_rounded,
                          iconColor: Colors.purple[700]!,
                          iconBg: Colors.purple[50]!,
                          title: "Aiuto e Supporto",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportPage())),
                        ),
                        const Divider(indent: 70),
                        _buildListTile(
                          key: const Key('btn_privacy'),
                          icon: Icons.privacy_tip_outlined,
                          iconColor: Colors.teal[700]!,
                          iconBg: Colors.teal[50]!,
                          title: "Privacy e Sicurezza",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacySecurityPage())),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // BOTTONE ESCI
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      key: const Key('btn_logout'),
                      onPressed: _signOut,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.withOpacity(0.5), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        backgroundColor: Colors.white,
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text("Disconnetti", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text("Versione 1.0.0", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
          ),

          // -----------------------------------------------------------
          // 2. LIVELLO SUPERIORE: L'HEADER (Ora cliccabile!)
          // -----------------------------------------------------------
          Positioned(
            top: 0, left: 0, right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[800]!, Colors.green[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // TITOLO CENTRATO
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.settings_suggest_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Impostazioni",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),

                      // PULSANTE INDIETRO
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => const AuthGate()),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 22
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWipBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Text(
        "WIP",
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange[800]),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
              letterSpacing: 1.2
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required VoidCallback onTap,
    String? trailingText,
    Key? key,
  }) {
    return ListTile(
      key: key,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(trailingText, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 16),
        ],
      ),
      onTap: onTap,
    );
  }
}
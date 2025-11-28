import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import 'rewards_screen.dart';
import 'settings_screen.dart';
import '../main.dart'; // Import main.dart to access supabase client

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Map<String, dynamic>?>? _userFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      // Fetch the user with the specific test email
      _userFuture = _fetchUserData();
    });
  }

  Future<Map<String, dynamic>?> _fetchUserData() async {
    try {
      final response = await supabase
          .from('utente')
          .select()
          .eq('email', 'mario.rossi.test@example.com')
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Error fetching data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;
    final Color lightGreen = Colors.green[100]!;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      // NAVBAR INFERIORE PERSONALIZZATA
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 2),

      body: FutureBuilder<Map<String, dynamic>?>(
          future: _userFuture,
          builder: (context, snapshot) {
            // Default/Loading values
            String nome = "Caricamento...";
            String cognome = "";
            String email = "...";
            String punti = "...";
            String ordini = "0"; // Placeholder

            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && snapshot.data != null) {
                final data = snapshot.data!;
                nome = data['nome'] ?? "Nome";
                cognome = data['cognome'] ?? "Cognome";
                email = data['email'] ?? "email@example.com";
                punti = (data['saldopunti'] ?? 0).toString();
              } else {
                nome = "Nessun dato";
                cognome = "";
                email = "Premi il tasto test";
                punti = "0";
              }
            }

            return Stack(
              children: [
                // SFONDO VERDE (HEADER)
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),

                // CONTENUTO SCORREVOLE
                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Intestazione
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Profilo",
                                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Le tue informazioni",
                                    style: TextStyle(fontSize: 16, color: Colors.white70),
                                  ),
                                ],
                              ),
                              // BOTTONE IMPOSTAZIONI ATTIVO
                              IconButton(
                                onPressed: () {
                                  // Apre la schermata impostazioni
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                  );
                                },
                                icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                                tooltip: "Impostazioni",
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // CARD BIANCA PRINCIPALE
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: lightGreen,
                                child: Icon(Icons.person_outline, size: 50, color: primaryGreen),
                              ),
                              const SizedBox(height: 15),
                              Text("$nome $cognome", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              const Text("Membro dal 2024", style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 25),
                              Row(
                                children: [
                                  Expanded(child: _buildStatBox(icon: Icons.calendar_today, value: ordini, label: "Ordini", color: primaryGreen)),
                                  const SizedBox(width: 15),
                                  Expanded(child: _buildStatBox(icon: Icons.workspace_premium, value: punti, label: "Punti", color: primaryGreen)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // LISTA INFORMAZIONI
                        _buildInfoCard(Icons.email_outlined, "Email", email, primaryGreen),
                        _buildInfoCard(Icons.phone_outlined, "Telefono", "+39 123 456 7890", primaryGreen),

                        const SizedBox(height: 30),

                        // TEST BUTTON FOR SUPABASE
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton.icon(
                            onPressed: () => _testWriteToSupabase(context),
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text("Test Scrittura & Lettura"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
      ),
    );
  }

  // WIDGET HELPER
  Widget _buildStatBox({required IconData icon, required String value, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color iconColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _testWriteToSupabase(BuildContext context) async {
    try {
      // Dati fittizi per il test
      final dummyUser = {
        'idutente': DateTime.now().millisecondsSinceEpoch.toString(), // ID univoco
        'nome': 'Mario',
        'cognome': 'Rossi',
        'email': 'mario.rossi.test@example.com',
        'password': 'passwordSegreta123',
        'saldopunti': 100,
        'codicerefferal': 'MARIO123',
        'fotoprofilo': 'https://example.com/avatar.jpg',
        'isadmin': false,
      };

      // Upsert: se esiste aggiorna, altrimenti crea
      await supabase.from('utente').upsert(dummyUser, onConflict: 'email');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dati scritti! Aggiornamento vista...'),
            backgroundColor: Colors.green,
          ),
        );
        // Ricarica i dati per mostrarli
        _refreshData();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}


import 'package:cityclean/models/user_profile.dart';
import 'package:cityclean/services/user_service.dart';
import 'package:cityclean/screens/profile_screen.dart';
import 'package:cityclean/screens/settings_screen.dart';
import 'package:cityclean/screens/guilds_list_screen.dart';
import 'package:cityclean/screens/redeemed_rewards_screen.dart';
import 'package:cityclean/screens/subscribed_events_screen.dart';
import 'package:cityclean/screens/qr_scanner_screen.dart';
import 'package:cityclean/screens/badge_screen.dart';
import 'package:cityclean/screens/objectives_screen.dart';
// CORREZIONE IMPORT: Uso il package completo per coerenza
import 'package:cityclean/screens/location_picker_screen.dart';
import 'package:cityclean/components/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:cityclean/services/report_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final UserService _userService = UserService();
  // Definizione corretta del servizio
  final ReportService _reportService = ReportService();
  Future<UserProfile>? _profileDataFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadProfile();
    }
  }

  void _loadProfile() {
    setState(() {
      _profileDataFuture = _userService.getCurrentUser();
    });
  }

  // --- FUNZIONE PER IL POPUP CREA EVENTO ---
  void _showCreateEventDialog(BuildContext context, String userId) {
    final eventTitleController = TextEditingController();
    final eventDescController = TextEditingController();
    final eventWasteTypeController = TextEditingController();
    DateTime eventDate = DateTime.now();
    LatLng? eventLocation;
    String eventLocationStatus = "Nessuna posizione selezionata";

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.event, color: Colors.green),
                    SizedBox(width: 10),
                    Text("Crea Nuovo Evento"),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Organizza un evento di pulizia futuro.", style: TextStyle(fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 15),

                      TextField(
                        controller: eventTitleController,
                        decoration: const InputDecoration(labelText: "Titolo Evento"),
                      ),
                      TextField(
                        controller: eventDescController,
                        decoration: const InputDecoration(labelText: "Descrizione"),
                        maxLines: 2,
                      ),
                      TextField(
                        controller: eventWasteTypeController,
                        decoration: const InputDecoration(labelText: "Tipologia Rifiuti Prevista"),
                      ),
                      const SizedBox(height: 10),

                      // Data Picker
                      Row(
                        children: [
                          const Text("Data:", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          Text(DateFormat('dd/MM/yyyy').format(eventDate)),
                          const Spacer(),
                          TextButton.icon(
                            icon: const Icon(Icons.calendar_month),
                            label: const Text("Cambia"),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: eventDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setState(() => eventDate = picked);
                            },
                          )
                        ],
                      ),

                      const SizedBox(height: 10),
                      const Text("Posizione:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(eventLocationStatus, style: TextStyle(fontSize: 12, color: eventLocation != null ? Colors.green : Colors.grey)),
                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.my_location),
                              label: const Text("Usa GPS"),
                              onPressed: () async {
                                try {
                                  Position pos = await Geolocator.getCurrentPosition();
                                  if (!context.mounted) return;
                                  setState(() {
                                    eventLocation = LatLng(pos.latitude, pos.longitude);
                                    eventLocationStatus = "GPS OK";
                                  });
                                } catch (e) {
                                  if (!context.mounted) return;
                                  setState(() => eventLocationStatus = "Errore GPS");
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.map),
                              label: const Text("Mappa"),
                              onPressed: () async {
                                final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LocationPickerScreen())
                                );
                                if (result != null && result is LatLng) {
                                  setState(() {
                                    eventLocation = result;
                                    eventLocationStatus = "Mappa OK";
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
                    onPressed: () async {
                      if (eventTitleController.text.isEmpty || eventLocation == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Titolo e Posizione obbligatori!")),
                        );
                        return;
                      }

                      try {
                        await _reportService.createEvent(
                          title: eventTitleController.text,
                          description: eventDescController.text,
                          wasteType: eventWasteTypeController.text,
                          date: eventDate,
                          latitude: eventLocation!.latitude,
                          longitude: eventLocation!.longitude,
                          userId: userId,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Evento creato!")),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore: $e")));
                        }
                      }
                    },
                    child: const Text("Segnala Evento"),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<UserProfile>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Errore nel caricamento dei dati"));
          }

          final userProfile = snapshot.data!;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        _buildHeader(context, userProfile),
                        const SizedBox(height: 15),
                        _buildProfileCard(context, userProfile),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Column(
                    children: [
                      _buildMainAction(context),
                      const SizedBox(height: 15),
                      _buildSubscribedEventsAction(context),
                      const SizedBox(height: 20),
                      _buildOptionsGrid(context, userProfile.id),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ciao ${user.nome}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Text(
              "Benvenuto nella tua home",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, UserProfile user) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        _loadProfile();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // CORREZIONE: withOpacity è deprecato, sostituito con withValues
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFE0F2F1),
              child: const Icon(Icons.person, size: 30, color: Colors.green),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(user.titolo ?? 'Membro CityClean', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text("${user.saldoPunti}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800])),
                  Text("Punti", style: TextStyle(color: Colors.green[800])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 90,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            // Assicurati che QrScannerScreen sia il nome della classe nel file qr_scanner_screen.dart
            MaterialPageRoute(builder: (context) => const QrScannerScreen()),
          );
        },
        icon: const Icon(Icons.qr_code_scanner, size: 30),
        label: const Text("Inizia a Riciclare", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildSubscribedEventsAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SubscribedEventsScreen()),
          );
        },
        icon: Icon(Icons.event_available_outlined, color: Colors.green[700]),
        label: Text(
          "I Miei Eventi",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.green[100],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          side: BorderSide(color: Colors.green[700]!, width: 2),
        ),
      ),
    );
  }

  Widget _buildOptionsGrid(BuildContext context, String userId) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildOptionCard(Icons.shield_outlined, "I Miei Badge", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const BadgeScreen()));
            })),
            const SizedBox(width: 15),
            Expanded(child: _buildOptionCard(Icons.card_giftcard_outlined, "Storico Premi", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RedeemedRewardsScreen()));
            })),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildOptionCard(Icons.group_work_outlined, "Cerca Gilda", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const GuildsListScreen()));
            })),
            const SizedBox(width: 15),
            Expanded(child: _buildOptionCard(Icons.add_circle_outline, "Segnala evento Futuro", onTap: () {
              _showCreateEventDialog(context, userId);
            })),
          ],
        ),
        const SizedBox(height: 15),
        _buildFullWidthCard(Icons.flag_outlined, "I Miei Obiettivi", onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ObjectivesScreen()));
        }),
      ],
    );
  }

  Widget _buildOptionCard(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: Colors.green[700]),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }

  // Helper per card a tutta larghezza
  Widget _buildFullWidthCard(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: Colors.green[700]),
            const SizedBox(width: 15),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
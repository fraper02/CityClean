import 'package:flutter/material.dart';
import 'profile_screen.dart'; // La destinazione finale

class RegisterPreferencesScreen extends StatefulWidget {
  final bool isEnglish;

  const RegisterPreferencesScreen({super.key, required this.isEnglish});

  @override
  State<RegisterPreferencesScreen> createState() => _RegisterPreferencesScreenState();
}

class _RegisterPreferencesScreenState extends State<RegisterPreferencesScreen> {
  // Stato
  String? _selectedCity;
  String _selectedRadius = "1 km";
  bool _notificationsEnabled = true;

  // Liste fittizie
  final List<String> _cities = ["Salerno", "Napoli", "Roma", "Milano", "Torino"];
  final List<String> _radii = ["500 m", "1 km", "2 km", "5 km"];

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[600]!;
    final Gradient bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.green[700]!, Colors.green[400]!],
    );

    // Testi localizzati in base alla scelta precedente
    final Map<String, String> texts = widget.isEnglish
        ? {
      'title': 'Preferences',
      'subtitle': 'Customize your experience',
      'city': 'City of Interest',
      'radius': 'Action Radius',
      'notifications': 'Enable Notifications',
      'finish': 'Start using CityClean',
    }
        : {
      'title': 'Preferenze',
      'subtitle': 'Personalizza la tua esperienza',
      'city': 'Città di Interesse',
      'radius': 'Raggio d\'Azione',
      'notifications': 'Abilita Notifiche',
      'finish': 'Inizia a usare CityClean',
    };

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                // Header con pulsante indietro
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 10),

                // TITOLO
                Text(
                  texts['title']!,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  texts['subtitle']!,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 50),

                // 1. SCELTA CITTÀ (Dropdown)
                _buildLabel(texts['city']!),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCity,
                      hint: Text("Seleziona una città", style: TextStyle(color: Colors.grey[600])),
                      isExpanded: true,
                      icon: const Icon(Icons.location_city, color: Colors.grey),
                      items: _cities.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCity = newValue;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 2. RAGGIO D'AZIONE (Chips selezionabili)
                _buildLabel(texts['radius']!),
                Wrap(
                  spacing: 10,
                  children: _radii.map((radius) {
                    final isSelected = _selectedRadius == radius;
                    return ChoiceChip(
                      label: Text(radius),
                      labelStyle: TextStyle(
                        color: isSelected ? primaryGreen : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      selected: isSelected,
                      selectedColor: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.white),
                      ),
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedRadius = radius;
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                // 3. NOTIFICHE (Switch)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active, color: Colors.white),
                          const SizedBox(width: 15),
                          Text(
                            texts['notifications']!,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      Switch(
                        value: _notificationsEnabled,
                        activeThumbColor: Colors.white,
                        activeTrackColor: primaryGreen,
                        onChanged: (bool value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // BOTTONE FINALE
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _selectedCity != null
                        ? () {
                      // Qui in futuro salverai tutto nel DB
                      // Per ora navighiamo all'app principale rimuovendo le schermate di registrazione dalla storia
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                            (route) => false,
                      );
                    }
                        : null, // Disabilitato se non è scelta la città
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                    child: Text(
                      texts['finish']!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
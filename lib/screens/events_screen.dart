import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import '../components/event_card.dart';
import '../models/event.dart';
import '../main.dart'; // Import for supabase client

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, bool> _subscribed = {}; // Mappa per controllare se un utente è iscritto o meno a quell'evento
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final response = await supabase.from('evento').select();

      /* --- MODIFICA DI DEBUG ---
      // Stampa il primo record ricevuto per ispezionare i nomi delle colonne.
      if (response.isNotEmpty) {
        debugPrint("Dati grezzi dal database (primo evento): ${response.first}");
      }
      -------------------------*/

      final List<Event> loadedEvents = (response as List)
          .map((data) => Event.fromJson(data as Map<String, dynamic>))
          .toList();
      
      loadedEvents.sort((a, b) => b.startDateTime.compareTo(a.startDateTime));

      if (mounted) {
        setState(() {
          _allEvents = loadedEvents;
          _filteredEvents = loadedEvents;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nel caricamento degli eventi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _runFilter(String enteredKeyword) {
    List<Event> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allEvents;
    } else {
      results = _allEvents
          .where((event) =>
              event.title.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
              event.location.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredEvents = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;
    const double fixedHeaderContentHeight = 170.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      body: Stack(
        children: [
          Container(
            height: 200,
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Eventi in Zona",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => _runFilter(value),
                    decoration: InputDecoration(
                      hintText: "Cerca eventi...",
                      prefixIcon: const Icon(Icons.search, color: Colors.green),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + fixedHeaderContentHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildEventsList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEventsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredEvents.isEmpty) {
      return const Center(
        child: Text(
          "Nessun evento trovato.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchEvents,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
        itemCount: _filteredEvents.length,
        itemBuilder: (context, index) {
          final event = _filteredEvents[index];

          return EventCard(
            event: event,
            isSubscribed: _subscribed[event.id] ?? false,
              onSubscribeToggle: () {
                setState(() {
                  _subscribed[event.id] = !(_subscribed[event.id] ?? false);
                });

                if (_subscribed[event.id] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Ti sei iscritto all'evento: ${event.title}"),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Hai annullato l'iscrizione all'evento: ${event.title}"),
                    ),
                  );
                }
              },
          );
        },
      ),
    );
  }
}

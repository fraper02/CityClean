import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import '../components/event_card.dart';
import '../models/event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  // Controller per la barra di ricerca
  final TextEditingController _searchController = TextEditingController();

  // Dati finti (Mock Data) - In futuro arriveranno dal DB
  final List<Event> _allEvents = [
    Event(
      id: '1',
      title: 'Pulizia Lungomare Trieste',
      imageUrl: 'https://images.unsplash.com/photo-1618477461853-5f8dd12033d6?q=80&w=2000&auto=format&fit=crop', // Immagine esempio spiaggia
      date: '15 Nov 2025',
      time: '09:00',
      location: 'Lungomare Trieste, Salerno',
      description: 'Raccolta rifiuti lungo il lungomare. Porta guanti e sacchetti, materiale aggiuntivo fornito.',
      category: 'Pulizia',
    ),
    Event(
      id: '2',
      title: 'Rimboschimento Parco Urbano',
      imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?q=80&w=2000&auto=format&fit=crop', // Immagine esempio parco
      date: '20 Nov 2025',
      time: '10:30',
      location: 'Parco del Mercatello, Salerno',
      description: 'Giornata dedicata alla piantumazione di nuovi alberi nel parco cittadino.',
      category: 'Verde',
    ),
    Event(
      id: '3',
      title: 'Workshop Riciclo Creativo',
      imageUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=2000&auto=format&fit=crop', // Immagine esempio workshop
      date: '01 Dic 2025',
      time: '16:00',
      location: 'Centro Sociale, Pastena',
      description: 'Impariamo a dare nuova vita agli oggetti di plastica e carta.',
      category: 'Workshop',
    ),
  ];

  // Lista che verrà visualizzata (filtrata)
  List<Event> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    // All'inizio, la lista filtrata è uguale a quella completa
    _filteredEvents = _allEvents;
  }

  // Funzione di ricerca
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

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Navbar Index 3 per "Eventi"
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 3),

      body: Stack(
        children: [
          // 1. HEADER VERDE
          Container(
            height: 200, // Header un po' più basso per lasciare spazio alla ricerca
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
            child: Column(
              children: [
                // 2. INTESTAZIONE E BARRA DI RICERCA
                Padding(
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

                      // BARRA DI RICERCA
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

                // 3. LISTA DEGLI EVENTI
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = _filteredEvents[index];
                      // Qui chiamiamo il nostro Widget separato!
                      return EventCard(
                        event: event,
                        onTap: () {
                          // Azione quando clicchi "Maggiori Info"
                          // Es: Navigator.push(context, MaterialPageRoute(...));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Hai selezionato: ${event.title}")),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
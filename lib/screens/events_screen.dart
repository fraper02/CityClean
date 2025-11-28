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

  // Dati finti (Mock Data) AGGIORNATI AL NUOVO MODEL
  final List<Event> _allEvents = [
    Event(
      id: '1',
      title: 'Pulizia Lungomare Trieste',
      imageUrl: 'https://images.unsplash.com/photo-1618477461853-5f8dd12033d6?q=80&w=2000&auto=format&fit=crop',
      // NOTA: Ora usiamo DateTime(anno, mese, giorno, ora, minuti)
      startDateTime: DateTime(2025, 11, 15, 9, 0),
      endDateTime: DateTime(2025, 11, 15, 13, 0), // Ipotizzo finisca alle 13:00
      location: 'Lungomare Trieste, Salerno',
      description: 'Raccolta rifiuti lungo il lungomare. Porta guanti e sacchetti.',
      category: 'Pulizia',
    ),
    Event(
      id: '2',
      title: 'Rimboschimento Parco Urbano',
      imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?q=80&w=2000&auto=format&fit=crop',
      startDateTime: DateTime(2025, 11, 20, 10, 30),
      endDateTime: DateTime(2025, 11, 20, 16, 00),
      location: 'Parco del Mercatello, Salerno',
      description: 'Giornata dedicata alla piantumazione di nuovi alberi.',
      category: 'Verde',
    ),
    Event(
      id: '3',
      title: 'Workshop Riciclo Creativo',
      imageUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=2000&auto=format&fit=crop',
      startDateTime: DateTime(2025, 12, 1, 16, 0),
      endDateTime: DateTime(2025, 12, 1, 18, 30),
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
    _filteredEvents = _allEvents;
  }

  // Funzione di ricerca (Invariata, cerca per titolo o luogo)
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
      // Assicurati che il tuo BottomNavBar accetti l'indice
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 3),

      body: Stack(
        children: [
          // 1. HEADER VERDE
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

                      // Passiamo l'oggetto Event aggiornato alla Card
                      return EventCard(
                        event: event,
                        onTap: () {
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
import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import '../components/event_card.dart';
import '../controllers/events_controller.dart';
import '../models/event.dart';
import '../main.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late final EventsController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = EventsController();
    _controller.loadEvents();

    _searchController.addListener(() {
      _controller.filterEvents(_searchController.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 3),
      body: ValueListenableBuilder<ScreenState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          switch (state) {
            case ScreenState.loading:
            case ScreenState.initial:
              return const Center(child: CircularProgressIndicator());

            case ScreenState.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _controller.loadEvents,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Riprova'),
                      ),
                    ],
                  ),
                ),
              );

            case ScreenState.success:
              return _buildContentUI();
          }
        },
      ),
    );
  }

  Widget _buildContentUI() {
    final Color primaryGreen = Colors.green[700]!;
    const double fixedHeaderContentHeight = 170.0;

    return Stack(
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
                const Text("Eventi in Zona", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Cerca eventi...",
                    prefixIcon: const Icon(Icons.search, color: Colors.green),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
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
    );
  }

  Widget _buildEventsList() {
    return ValueListenableBuilder<List<Event>>(
      valueListenable: _controller.filteredEvents,
      builder: (context, events, _) {
        if (events.isEmpty) {
          return const Center(child: Text("Nessun evento trovato.", style: TextStyle(fontSize: 16, color: Colors.grey)));
        }

        return ValueListenableBuilder<Set<String>>(
          valueListenable: _controller.subscribedEventIds,
          builder: (context, subscribedIds, _) {
            return RefreshIndicator(
              onRefresh: _controller.loadEvents,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final isSubscribed = subscribedIds.contains(event.id);

                  return EventCard(
                    event: event,
                    isSubscribed: isSubscribed,
                    // Lo Screen ora si limita a chiamare il controller, passando il contesto.
                    onSubscribeToggle: () => _controller.toggleSubscription(context, event.id, event.title),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

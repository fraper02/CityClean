// lib/screens/subscribed_events_screen.dart

import 'package:flutter/material.dart';
import '../controllers/subscribed_events_controller.dart';
import '../components/event_card.dart';
import '../models/event.dart';

// Non serve definire ScreenState qui, viene dal controller

class SubscribedEventsScreen extends StatefulWidget {
  const SubscribedEventsScreen({super.key});

  @override
  State<SubscribedEventsScreen> createState() => _SubscribedEventsScreenState();
}

class _SubscribedEventsScreenState extends State<SubscribedEventsScreen> {
  late final SubscribedEventsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SubscribedEventsController();
    _controller.loadSubscribedEvents();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- NUOVA FUNZIONE PER GESTIRE L'ANNULLAMENTO CON POPUP ---
  Future<void> _handleUnsubscribe(Event event) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annulla Iscrizione'),
        content: Text('Sei sicuro di voler annullare l\'iscrizione a "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Mantieni'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Annulla Iscrizione'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _controller.unsubscribeFromEvent(event.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Iscrizione a "${event.title}" annullata.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I Miei Eventi'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
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
                      ElevatedButton(
                        onPressed: _controller.loadSubscribedEvents,
                        child: const Text('Riprova'),
                      ),
                    ],
                  ),
                ),
              );

            case ScreenState.success:
              return _buildEventsList();
          }
        },
      ),
    );
  }

  Widget _buildEventsList() {
    return ValueListenableBuilder<List<Event>>(
      valueListenable: _controller.subscribedEvents,
      builder: (context, events, _) {
        if (events.isEmpty) {
          return const Center(
            child: Text(
              "Non sei iscritto a nessun evento.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.loadSubscribedEvents,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCard(
                event: event,
                isSubscribed: true,
                onSubscribeToggle: () => _handleUnsubscribe(event),
              );
            },
          ),
        );
      },
    );
  }
}

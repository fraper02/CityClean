import 'package:cityclean/components/bottom_nav_bar.dart';
import 'package:cityclean/components/event_card.dart';
import 'package:cityclean/controllers/subscribed_events_controller.dart';
import 'package:cityclean/models/event.dart';
import 'package:flutter/material.dart';

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

  void _handleUnsubscribe(Event event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annulla Iscrizione'),
        // CORREZIONE DEFINITIVA: Parentesi corrette
        content: SingleChildScrollView(
          child: Text('Sei sicuro di voler annullare l\'iscrizione a "${event.titolo}"?'),
        ),
        actions: [
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8.0,
            children: [
              TextButton(child: const Text('Chiudi'), onPressed: () => Navigator.pop(ctx)),
              TextButton(
                child: const Text('Conferma', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await _controller.unsubscribeFromEvent(event.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Hai annullato l\'iscrizione a: ${event.titolo}'), backgroundColor: Colors.orange),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Le tue Iscrizioni"), centerTitle: true),
      bottomNavigationBar: const CityCleanBottomNavBar(currentIndex: 4),
      body: ValueListenableBuilder<ScreenState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          if (state == ScreenState.loading || state == ScreenState.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state == ScreenState.error) {
            return Center(child: Text(_controller.errorMessage.value, style: const TextStyle(color: Colors.red)));
          }
          return ValueListenableBuilder<List<Event>>(
            valueListenable: _controller.subscribedEvents,
            builder: (context, events, _) {
              if (events.isEmpty) {
                return const Center(child: Text("Non sei iscritto a nessun evento."));
              }
              return RefreshIndicator(
                onRefresh: _controller.loadSubscribedEvents,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
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
        },
      ),
    );
  }
}

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            const SizedBox(width: 10),
            const Text('Attenzione'),
          ],
        ),
        content: Text(
          'Sei sicuro di voler annullare l\'iscrizione a "${event.titolo}"?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            child: const Text('Annulla', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _controller.unsubscribeFromEvent(event.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Iscrizione annullata: ${event.titolo}'),
                      backgroundColor: Colors.orange[800],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Conferma', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Altezza dell'header verde
    const double headerHeight = 220.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // RIMOSSA LA BOTTOM NAV BAR
      body: Stack(
        children: [
          // 1. LIVELLO SFONDO: La Lista
          Positioned.fill(
            child: ValueListenableBuilder<ScreenState>(
              valueListenable: _controller.state,
              builder: (context, state, _) {
                if (state == ScreenState.loading || state == ScreenState.initial) {
                  return Center(child: CircularProgressIndicator(color: Colors.green[700]));
                }

                if (state == ScreenState.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: headerHeight),
                      child: Text(
                        _controller.errorMessage.value,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  );
                }

                return ValueListenableBuilder<List<Event>>(
                  valueListenable: _controller.subscribedEvents,
                  builder: (context, events, _) {
                    if (events.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: _controller.loadSubscribedEvents,
                      color: Colors.green[700],
                      backgroundColor: Colors.white,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          top: headerHeight + 20,
                          left: 20,
                          right: 20,
                          bottom: 20, // Spazio in fondo per non tagliare l'ultima card
                        ),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: EventCard(
                              event: event,
                              isSubscribed: true,
                              onSubscribeToggle: () => _handleUnsubscribe(event),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 2. LIVELLO PRIMO PIANO: L'Header Verde
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green[800]!, Colors.green[600]!],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green[900]!.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
            ),
          ),

          // 3. LIVELLO CONTENUTO HEADER
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TASTO INDIETRO
                    Row(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.of(context).pushReplacementNamed('/home');
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2), // Effetto vetro
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 22
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // TITOLO E ICONA
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.event_available_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          "Le tue Iscrizioni",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Text(
                        "Gestisci qui gli eventi a cui partecipi.",
                        style: TextStyle(fontSize: 15, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)
              ],
            ),
            child: Icon(Icons.event_busy_rounded, size: 80, color: Colors.grey[300]),
          ),
          const SizedBox(height: 20),
          Text(
            "Nessuna iscrizione attiva",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            "Iscriviti agli eventi per vederli qui.",
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
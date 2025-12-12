import 'package:cityclean/controllers/objectives_controller.dart';
import 'package:cityclean/models/obiettivo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ObjectivesScreen extends StatefulWidget {
  const ObjectivesScreen({super.key});

  @override
  State<ObjectivesScreen> createState() => _ObjectivesScreenState();
}

class _ObjectivesScreenState extends State<ObjectivesScreen> {
  late final ObjectivesController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = ObjectivesController();
    _controller.loadObjectives();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Prepariamo le pagine mantenendo la logica originale
    final List<Widget> pages = [
      _buildObjectivesList(context, _controller.availableObjectives, false),
      _buildObjectivesList(context, _controller.completedObjectives, true),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("I Tuoi Obiettivi", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: ValueListenableBuilder<ObjectivesScreenState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          if (state == ObjectivesScreenState.loading || state == ObjectivesScreenState.initial) {
            return Center(child: CircularProgressIndicator(color: Colors.green[700]));
          }
          if (state == ObjectivesScreenState.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 50, color: Colors.red),
                    const SizedBox(height: 10),
                    Text(
                      _controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }
          // Mostra la pagina corrente
          return pages[_currentIndex];
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green[700],
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.flag_circle_outlined, key: Key('tab_available')), // ID TEST
              activeIcon: Icon(Icons.flag_circle),
              label: 'Disponibili',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline, key: Key('tab_completed')), // ID TEST
              activeIcon: Icon(Icons.check_circle),
              label: 'Conseguiti',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectivesList(BuildContext context, ValueNotifier<List<Obiettivo>> notifier, bool areCompleted) {
    return ValueListenableBuilder<List<Obiettivo>>(
      valueListenable: notifier,
      builder: (context, objectives, _) {
        if (objectives.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  areCompleted ? Icons.emoji_events_outlined : Icons.assignment_outlined,
                  size: 60,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 15),
                Text(
                  areCompleted
                      ? "Ancora nessun traguardo raggiunto.\nDatti da fare!"
                      : "Nessun nuovo obiettivo disponibile.\nTorna presto!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: objectives.length,
          separatorBuilder: (context, index) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            final obiettivo = objectives[index];
            return _buildObjectiveCard(context, obiettivo);
          },
        );
      },
    );
  }

  Widget _buildObjectiveCard(BuildContext context, Obiettivo obiettivo) {
    final bool isCompleted = obiettivo.isConseguito;
    final bool isExpired = obiettivo.isTempo &&
        obiettivo.dataFine != null &&
        DateTime.now().isAfter(obiettivo.dataFine!) &&
        !isCompleted;

    // Colori dinamici in base allo stato
    Color iconBgColor = isCompleted ? Colors.green[50]! : Colors.orange[50]!;
    Color iconColor = isCompleted ? Colors.green[700]! : Colors.orange[700]!;
    IconData mainIcon = isCompleted ? Icons.emoji_events : Icons.track_changes;

    if (isExpired) {
      iconBgColor = Colors.red[50]!;
      iconColor = Colors.red[400]!;
      mainIcon = Icons.timer_off_outlined;
    }

    return Container(
      key: Key('card_objective_${obiettivo.id}'), // ID TEST
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _controller.showObjectiveDetails(context, obiettivo),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // 1. ICONA
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(mainIcon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),

                // 2. CONTENUTO TESTUALE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        obiettivo.nome,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isExpired ? Colors.grey : Colors.black87,
                          decoration: isExpired ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // INFO DATA
                      if (obiettivo.isTempo && obiettivo.dataFine != null && !isCompleted)
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 14, color: isExpired ? Colors.red : Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              isExpired
                                  ? 'Scaduto il ${DateFormat('dd/MM').format(obiettivo.dataFine!)}'
                                  : 'Scade: ${DateFormat('dd/MM/yyyy').format(obiettivo.dataFine!)}',
                              style: TextStyle(
                                color: isExpired ? Colors.red : Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      else if (isCompleted && obiettivo.dataCompletamento != null)
                        Row(
                          children: [
                            Icon(Icons.check_circle_outline, size: 14, color: Colors.green[600]),
                            const SizedBox(width: 4),
                            Text(
                              'Completato: ${DateFormat('dd/MM/yyyy').format(obiettivo.dataCompletamento!)}',
                              style: TextStyle(color: Colors.green[700], fontSize: 12),
                            ),
                          ],
                        )
                      else
                        Text(
                          "Obiettivo standard",
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                    ],
                  ),
                ),

                // 3. BADGE PUNTI
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green[100] : Colors.amber[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.star, size: 14, color: isCompleted ? Colors.green[800] : Colors.amber[800]),
                      const SizedBox(height: 2),
                      Text(
                        '+${obiettivo.puntiRicompensa}',
                        style: TextStyle(
                          color: isCompleted ? Colors.green[900] : Colors.amber[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
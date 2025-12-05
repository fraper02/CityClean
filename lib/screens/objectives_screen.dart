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
    final List<Widget> pages = [
      _buildObjectivesList(context, _controller.availableObjectives, false),
      _buildObjectivesList(context, _controller.completedObjectives, true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("I Tuoi Obiettivi"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<ObjectivesScreenState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          if (state == ObjectivesScreenState.loading || state == ObjectivesScreenState.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state == ObjectivesScreenState.error) {
            return Center(child: Text(_controller.errorMessage.value));
          }
          // Mostra la pagina corrente (Disponibili o Conseguiti)
          return pages[_currentIndex];
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Disponibili',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Conseguiti',
          ),
        ],
      ),
    );
  }

  Widget _buildObjectivesList(BuildContext context, ValueNotifier<List<Obiettivo>> notifier, bool areCompleted) {
    return ValueListenableBuilder<List<Obiettivo>>(
      valueListenable: notifier,
      builder: (context, objectives, _) {
        if (objectives.isEmpty) {
          return Center(child: Text(areCompleted ? "Non hai ancora completato nessun obiettivo." : "Nessun nuovo obiettivo disponibile."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: objectives.length,
          itemBuilder: (context, index) {
            final obiettivo = objectives[index];
            return _buildObjectiveCard(context, obiettivo);
          },
        );
      },
    );
  }

  Widget _buildObjectiveCard(BuildContext context, Obiettivo obiettivo) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        onTap: () => _controller.showObjectiveDetails(context, obiettivo),
        leading: obiettivo.isConseguito
            ? Icon(Icons.check_circle, color: Colors.green[600], size: 28)
            : Icon(Icons.emoji_events_outlined, color: Colors.amber[800], size: 28),
        title: Text(obiettivo.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${obiettivo.puntiRicompensa} punti'),
            if (obiettivo.isTempo && obiettivo.dataFine != null && !obiettivo.isConseguito)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.watch_later_outlined, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Scade il: ${DateFormat('dd/MM/yyyy').format(obiettivo.dataFine!)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            if (obiettivo.isConseguito && obiettivo.dataCompletamento != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Conseguito il: ${DateFormat('dd/MM/yyyy').format(obiettivo.dataCompletamento!)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}

import 'package:cityclean/components/network_image_with_fallback.dart';
import 'package:cityclean/controllers/missions_controller.dart';
import 'package:cityclean/models/missione.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  late final MissionsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MissionsController();
    _controller.loadMissions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Missioni"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: ValueListenableBuilder<MissionsScreenState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          if (state == MissionsScreenState.loading || state == MissionsScreenState.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state == MissionsScreenState.error) {
            return Center(child: Text(_controller.errorMessage.value));
          }
          return _buildMissionsList();
        },
      ),
    );
  }

  Widget _buildMissionsList() {
    return ValueListenableBuilder<List<Missione>>(
      valueListenable: _controller.missions,
      builder: (context, missions, _) {
        if (missions.isEmpty) {
          return const Center(child: Text("Nessuna missione disponibile al momento."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: missions.length,
          itemBuilder: (context, index) {
            return _buildMissionCard(missions[index]);
          },
        );
      },
    );
  }

  Widget _buildMissionCard(Missione missione) {
    final progress = missione.obiettivoTarget > 0 ? missione.progressoAttuale / missione.obiettivoTarget : 0.0;
    final bool isExpired = missione.stato == MissionStatus.scaduta;
    final bool isCompleted = missione.stato == MissionStatus.completata;

    return Opacity(
      opacity: isExpired ? 0.6 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: isCompleted ? Colors.green.withOpacity(0.8) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                missione.titolo,
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  decoration: isExpired ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
              const SizedBox(height: 8),
              Text(missione.descrizione, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 16),

              if (missione.stato == MissionStatus.inCorso)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        color: Colors.green,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text("${missione.progressoAttuale} / ${missione.obiettivoTarget}", style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              
              const Divider(height: 32),

              _buildSectionHeader("Premio", Icons.emoji_events_outlined),
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 40, height: 40,
                    child: NetworkImageWithFallback(imageUrl: missione.badgePremio.urlIcona, fallbackWidget: const Icon(Icons.shield)),
                  ),
                  const SizedBox(width: 12),
                  Text(missione.badgePremio.nome, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 16),

              if (missione.dataScadenza != null && !isCompleted)
                _buildInfoRow(Icons.watch_later_outlined, "Scade il: ${DateFormat('dd/MM/yyyy').format(missione.dataScadenza!)}", isExpired ? Colors.red : Colors.grey[700]),

              const SizedBox(height: 16),
              _buildStatusButton(missione),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, [Color? color]) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: color ?? Colors.grey[700])),
      ],
    );
  }

  Widget _buildStatusButton(Missione missione) {
    switch (missione.stato) {
      // CORREZIONE: Usiamo i nomi corretti dell'enum
      case MissionStatus.nonIniziata:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _controller.acceptMission(context, missione.id),
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: const Text("Inizia Missione", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
          ),
        );
      case MissionStatus.inCorso:
        return _buildInfoRow(Icons.run_circle_outlined, "Missione in corso...", Colors.blue[700]);
      case MissionStatus.completata:
        return _buildInfoRow(Icons.check_circle, "Missione completata!", Colors.green[800]);
      case MissionStatus.scaduta:
        return _buildInfoRow(Icons.error_outline, "Missione scaduta", Colors.red[700]);
    }
  }
}

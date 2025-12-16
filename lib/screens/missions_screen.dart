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
      backgroundColor: Colors.grey[50],
      body: ValueListenableBuilder<MissionsScreenState>(
        valueListenable: _controller.state,
        builder: (context, state, _) {
          if (state == MissionsScreenState.loading || state == MissionsScreenState.initial) {
            return Center(child: CircularProgressIndicator(color: Colors.green[700]));
          }
          if (state == MissionsScreenState.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // 1. HEADER ELASTICO
              SliverAppBar(
                pinned: true,
                expandedHeight: 220.0,
                backgroundColor: Colors.green[700],
                elevation: 0,
                leading: IconButton(
                  key: const Key('btn_back_missions'), // ID TEST
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 16),
                  collapseMode: CollapseMode.parallax,
                  title: const Text(
                    "Missioni & Sfide",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[800]!, Colors.green[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.rocket_launch_rounded, size: 45, color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Completa obiettivi, guadagna badge!",
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. LISTA MISSIONI
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: ValueListenableBuilder<List<Missione>>(
                  valueListenable: _controller.missions,
                  builder: (context, missions, _) {
                    if (missions.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 50.0),
                            child: Column(
                              children: [
                                Icon(Icons.bedtime_outlined, size: 60, color: Colors.grey),
                                SizedBox(height: 10),
                                Text("Nessuna missione attiva al momento."),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          return _buildMissionCard(missions[index]);
                        },
                        childCount: missions.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMissionCard(Missione missione) {
    final progress = missione.obiettivoTarget > 0 ? missione.progressoAttuale / missione.obiettivoTarget : 0.0;
    final bool isExpired = missione.stato == MissionStatus.scaduta;
    final bool isCompleted = missione.stato == MissionStatus.completata;
    final bool isInProgress = missione.stato == MissionStatus.inCorso;

    return Container(
      key: Key('card_mission_${missione.id}'), // ID TEST
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isCompleted ? Border.all(color: Colors.green.withOpacity(0.5), width: 1.5) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER CARD (Titolo e Badge Stato)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        missione.titolo,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isExpired ? Colors.grey : Colors.black87,
                          decoration: isExpired ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        missione.descrizione,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _buildStatusBadge(missione.stato),
              ],
            ),
          ),

          // PROGRESS BAR (Solo se in corso o completata)
          if (isInProgress || isCompleted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Progresso", style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold)),
                      Text(
                        "${missione.progressoAttuale} / ${missione.obiettivoTarget}",
                        style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[100],
                      color: isCompleted ? Colors.green : Colors.blue,
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 30, thickness: 0.5),

          // FOOTER CARD (Premio e Bottone)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                // PREMIO
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: NetworkImageWithFallback(
                      imageUrl: missione.badgePremio.urlIcona,
                      fallbackWidget: Icon(Icons.shield, color: Colors.amber[800]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ricompensa", style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(
                        missione.badgePremio.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (missione.dataScadenza != null && !isCompleted && !isExpired)
                        Text(
                          "Scade: ${DateFormat('dd/MM').format(missione.dataScadenza!)}",
                          style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                        ),
                    ],
                  ),
                ),

                // BOTTONE AZIONE (Se non iniziata)
                if (missione.stato == MissionStatus.nonIniziata)
                  ElevatedButton(
                    key: Key('btn_start_mission_${missione.id}'), // ID TEST
                    onPressed: () => _controller.acceptMission(context, missione.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.green.withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text("Avvia", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(MissionStatus status) {
    String text;
    Color color;
    Color bg;

    switch (status) {
      case MissionStatus.nonIniziata:
        text = "Nuova";
        color = Colors.blue[700]!;
        bg = Colors.blue[50]!;
        break;
      case MissionStatus.inCorso:
        text = "In Corso";
        color = Colors.orange[800]!;
        bg = Colors.orange[50]!;
        break;
      case MissionStatus.completata:
        text = "Fatta";
        color = Colors.green[700]!;
        bg = Colors.green[50]!;
        break;
      case MissionStatus.scaduta:
        text = "Scaduta";
        color = Colors.grey[600]!;
        bg = Colors.grey[200]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
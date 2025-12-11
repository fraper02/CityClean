import 'package:cityclean/controllers/admin/segnalazioni_controller.dart';
import 'package:cityclean/models/segnalazione.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

const Color adminPrimaryColor = Color(0xFF2E7D32);

class AdminSegnalazioniPage extends StatefulWidget {
  const AdminSegnalazioniPage({super.key});

  @override
  AdminSegnalazioniPageState createState() => AdminSegnalazioniPageState();
}

class AdminSegnalazioniPageState extends State<AdminSegnalazioniPage> {
  late final SegnalazioniController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SegnalazioniController();
    _controller.loadSegnalazioni();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void refreshSegnalazioni() {
    _controller.loadSegnalazioni();
  }

  Future<void> _launchMaps(double lat, double lng) async {
    final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossibile avviare le mappe.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SegnalazioniState>(
      valueListenable: _controller.state,
      builder: (context, state, _) {
        if (state == SegnalazioniState.loading) {
          return const Center(child: CircularProgressIndicator(color: adminPrimaryColor));
        }
        if (state == SegnalazioniState.error) {
          return Center(child: Text('Errore: ${_controller.errorMessage.value}'));
        }
        return ValueListenableBuilder<List<Segnalazione>>(
          valueListenable: _controller.segnalazioni,
          builder: (context, segnalazioni, _) {
            if (segnalazioni.isEmpty) {
              return const Center(child: Text('Nessuna segnalazione trovata.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: segnalazioni.length,
              itemBuilder: (context, index) => _buildSegnalazioneCard(segnalazioni[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildSegnalazioneCard(Segnalazione segnalazione) {
    final bool isPending = segnalazione.accettata == null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text('ID: ${segnalazione.id.substring(0, 8)}...', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                _buildStatusChip(segnalazione.accettata),
              ],
            ),
            const Divider(height: 20),
            _buildInfoRow(Icons.person_outline, 'Utente', segnalazione.userEmail ?? 'N/D'),
            _buildInfoRow(Icons.source, 'Fonte', segnalazione.fonteDato ?? 'N/D'),
            _buildInfoRow(Icons.warning_amber_rounded, 'Livello Inquinamento', segnalazione.pollutionLevel ?? 'N/D'),
            _buildInfoRow(Icons.category_outlined, 'Tipo', segnalazione.pollutionType ?? 'N/D'),
            _buildInfoRow(Icons.location_on, 'Coordinate', '${segnalazione.latitude?.toStringAsFixed(4)}, ${segnalazione.longitude?.toStringAsFixed(4)}'),
            if (segnalazione.lastUpdated != null)
              _buildInfoRow(Icons.date_range, 'Data', DateFormat('dd/MM/yyyy HH:mm').format(segnalazione.lastUpdated!)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (segnalazione.latitude != null && segnalazione.longitude != null)
                  IconButton(
                    icon: const Icon(Icons.map_outlined, color: adminPrimaryColor),
                    tooltip: 'Mostra su Mappa',
                    onPressed: () => _launchMaps(segnalazione.latitude!, segnalazione.longitude!),
                  ),
                const Spacer(),
                if (isPending)
                  ...[
                    TextButton(
                      child: const Text('Rifiuta', style: TextStyle(color: Colors.red)),
                      onPressed: () => _controller.updateStatus(segnalazione.id, false),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: adminPrimaryColor, foregroundColor: Colors.white),
                      child: const Text('Approva'),
                      onPressed: () => _controller.updateStatus(segnalazione.id, true),
                    ),
                  ]
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: TextStyle(color: Colors.grey[800]))),
      ]),
    );
  }

  Widget _buildStatusChip(bool? accettata) {
    Color color;
    String label;
    if (accettata == null) {
      color = Colors.orange;
      label = 'In Attesa';
    } else if (accettata) {
      color = adminPrimaryColor;
      label = 'Approvata';
    } else {
      color = Colors.red;
      label = 'Rifiutata';
    }
    return Chip(label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 8));
  }
}

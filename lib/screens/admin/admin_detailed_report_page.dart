import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color adminPrimaryColor = Color(0xFF2E7D32);

class AdminDetailedReportPage extends StatelessWidget {
  final String title;
  final List<dynamic> data;

  const AdminDetailedReportPage({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
      ),
      body: data.isEmpty
          ? const Center(child: Text('Nessun dato da visualizzare.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index] as Map<String, dynamic>;
                final isConferimento = item.containsKey('data_conferimento');

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isConferimento ? 'Conferimento #${index + 1}' : 'Segnalazione #${index + 1}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: adminPrimaryColor,
                          ),
                        ),
                        const Divider(height: 20),
                        ..._buildItemRows(item),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  List<Widget> _buildItemRows(Map<String, dynamic> item) {
    return item.entries.map((entry) {
      String formattedValue = entry.value?.toString() ?? 'N/D';
      IconData? icon = _getIconForKey(entry.key);

      if ((entry.key.toString().contains('_data') || entry.key.toString().contains('creazione')) && entry.value != null) {
        try {
          formattedValue = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(entry.value));
        } catch (e) { /* ignora */ }
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 12),
            ],
            Text('${_formatKey(entry.key)}:', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Expanded(child: Text(formattedValue, style: TextStyle(color: Colors.grey[800]))),
          ],
        ),
      );
    }).toList();
  }

  String _formatKey(String key) {
    return key.replaceAll('_', ' ').capitalize();
  }

  IconData? _getIconForKey(String key) {
    switch (key) {
      case 'id_utente': return Icons.person;
      case 'id_punto_raccolta': return Icons.location_pin;
      case 'punti_guadagnati': return Icons.star;
      case 'data_conferimento': return Icons.calendar_today;
      case 'peso_co2_totale': return Icons.eco;
      case 'livelloinquinamento': return Icons.warning;
      case 'tipoinquinamento': return Icons.category;
      case 'stato': return Icons.check_circle;
      case 'accettata': return Icons.thumb_up;
      default: return null;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

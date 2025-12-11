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
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.surface,
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: adminPrimaryColor,
                          ),
                        ),
                        const Divider(),
                        ...item.entries.map((entry) {
                          String value = entry.value?.toString() ?? 'N/D';
                          // Formattazione speciale per le date
                          if ((entry.key.toString().contains('_data') || entry.key.toString().contains('creazione')) && entry.value != null) {
                            try {
                              value = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(entry.value));
                            } catch (e) { /* ignora se il formato non è valido */ }
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${entry.key}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Expanded(child: Text(value)),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

const Color adminPrimaryColor = Color(0xFF2E7D32);

class EventCard extends StatelessWidget {
  final Event event;
  final bool isSubscribed;
  final VoidCallback onSubscribeToggle;

  const EventCard({
    super.key,
    required this.event,
    required this.onSubscribeToggle,
    this.isSubscribed = false,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate = event.dataOraInizio != null
        ? DateFormat('dd MMM yyyy', 'it_IT').format(event.dataOraInizio!)
        : 'Data non disponibile';
    final String formattedTime = event.dataOraInizio != null
        ? DateFormat('HH:mm').format(event.dataOraInizio!)
        : 'Orario non disponibile';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: event.immagine != null && event.immagine!.isNotEmpty
                    ? Image.network(
                        event.immagine!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, error, stackTrace) => _buildImageError(),
                      )
                    : _buildImagePlaceholder(),
              ),
              if (event.categoria != null && event.categoria!.isNotEmpty)
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: adminPrimaryColor, borderRadius: BorderRadius.circular(20)),
                    child: Text(event.categoria!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.titolo, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 15),
                _buildInfoRow(Icons.calendar_today_outlined, formattedDate),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.access_time, formattedTime),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on_outlined, event.localita),
                const SizedBox(height: 15),
                Text(
                  event.descrizione,
                  style: TextStyle(color: Colors.grey[700], height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onSubscribeToggle,
                    // CORREZIONE: Icone modificate per essere più intuitive
                    icon: Icon(isSubscribed ? Icons.person_remove_outlined : Icons.person_add_alt_1_outlined, size: 20, color: Colors.white),
                    label: Text(isSubscribed ? "Annulla iscrizione" : "Iscrivimi", style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSubscribed ? Colors.orange[700] : adminPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 18, color: adminPrimaryColor),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500))),
    ]);
  }

  Widget _buildImageError() {
    return Container(height: 180, color: Colors.grey[200], child: const Center(child: Icon(Icons.error_outline, size: 50, color: Colors.grey)));
  }

  Widget _buildImagePlaceholder() {
    return Container(height: 180, color: Colors.grey[200], child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)));
  }
}

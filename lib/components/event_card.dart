import 'package:flutter/material.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap; // Per gestire il click sul pulsante

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. IMMAGINE E BADGE
          Stack(
            children: [
              // Immagine arrotondata in alto
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network( // Usa network per immagini dal web (o asset per locali)
                  event.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, stackTrace) {
                    return Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey))
                    );
                  },
                ),
              ),
              // Badge Categoria (in alto a destra)
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 2. CONTENUTO TESTUALE
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titolo
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800], // Colore verde come nell'immagine
                  ),
                ),
                const SizedBox(height: 15),

                // Info: Data, Ora, Luogo
                _buildInfoRow(Icons.calendar_today_outlined, event.date),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.access_time, event.time),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on_outlined, event.location),

                const SizedBox(height: 15),

                // Descrizione
                Text(
                  event.description,
                  style: TextStyle(color: Colors.grey[700], height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 20),

                // Bottone Maggiori Info
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.info_outline, size: 20),
                    label: const Text("Maggiori Info"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
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

  // Helper per le righe di info (Data, Ora, Luogo)
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.green[700]),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
// Modello per i Punti di Raccolta (Eco-Compattatori)
class EcoPoint {
  final String id;
  final String name;
  final String type; // Es. "Plastica", "Vetro", "Generico"
  // In una mappa reale useresti LatLng. Qui usiamo coordinate relative (0.0 a 1.0)
  // per posizionarli sull'immagine di sfondo.
  final double x;
  final double y;

  EcoPoint({
    required this.id,
    required this.name,
    required this.type,
    required this.x,
    required this.y,
  });
}

// Modello per le Zone Inquinate
class PollutedZone {
  final String id;
  final double x;
  final double y;
  final double radius; // Dimensione dell'area
  final String severity; // "Alta", "Media"

  PollutedZone({
    required this.id,
    required this.x,
    required this.y,
    required this.radius,
    required this.severity,
  });
}
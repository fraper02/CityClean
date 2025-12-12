class SessioneRaccolta {
  final String idsessione;
  final String idutente;
  final String idpuntoraccolta;
  final DateTime timestamp;
  final int puntiguadagnati;
  final String dettaglirifiuto;
  final Duration durataSessione;

  SessioneRaccolta({
    required this.idsessione,
    required this.idutente,
    required this.idpuntoraccolta,
    required this.timestamp,
    required this.puntiguadagnati,
    required this.dettaglirifiuto,
    required this.durataSessione,
  });

  Map<String, dynamic> toJson() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(durataSessione.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(durataSessione.inSeconds.remainder(60));
    String formattedDuration =
        "${twoDigits(durataSessione.inHours)}:$twoDigitMinutes:$twoDigitSeconds";

    return {
      'idsessione': idsessione,
      'idutente': idutente,
      'idpuntoraccolta': idpuntoraccolta,
      'timestamp': timestamp.toIso8601String(),
      'puntiguadagnati': puntiguadagnati,
      'dettaglirifiuto': dettaglirifiuto,
      'durata_sessione': formattedDuration,
    };
  }
}

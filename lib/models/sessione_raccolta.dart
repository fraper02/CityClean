class SessioneRaccolta {
  final String idsessione;
  final String idutente;
  final String idpuntoraccolta;
  final DateTime timestamp;
  final int puntiguadagnati;
  final String dettaglirifiuto;
  final Duration durata_sessione;

  SessioneRaccolta({
    required this.idsessione,
    required this.idutente,
    required this.idpuntoraccolta,
    required this.timestamp,
    required this.puntiguadagnati,
    required this.dettaglirifiuto,
    required this.durata_sessione,
  });

  Map<String, dynamic> toJson() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(durata_sessione.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(durata_sessione.inSeconds.remainder(60));
    String formattedDuration =
        "${twoDigits(durata_sessione.inHours)}:$twoDigitMinutes:$twoDigitSeconds";

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

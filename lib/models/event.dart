class Event {
  final String id;
  final String titolo;
  final String descrizione;
  final String localita;
  final DateTime? dataOraInizio;
  final DateTime? dataOraFine;
  final String? categoria;
  final String? immagine;
  final double? longitude;
  final double? latitude;
  final int participantCount; // Campo calcolato

  Event({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.localita,
    this.dataOraInizio,
    this.dataOraFine,
    this.categoria,
    this.immagine,
    this.longitude,
    this.latitude,
    this.participantCount = 0,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    // CORREZIONE: Legge correttamente il conteggio dei partecipanti
    final participationData = json['partecipazione'] as List? ?? [];
    final count = participationData.isNotEmpty
        ? (participationData[0]['count'] as num? ?? 0).toInt()
        : 0;

    return Event(
      id: json['idevento'] as String,
      titolo: json['titolo'] as String? ?? 'N/D',
      descrizione: json['descrizione'] as String? ?? 'Nessuna descrizione',
      localita: json['localita'] as String? ?? 'N/D',
      dataOraInizio: json['dataorainizio'] != null ? DateTime.parse(json['dataorainizio']) : null,
      dataOraFine: json['dataorafine'] != null ? DateTime.parse(json['dataorafine']) : null,
      categoria: json['categoria'] as String?,
      immagine: json['immagine'] as String?,
      longitude: (json['longitudine'] as num?)?.toDouble(),
      latitude: (json['latitudine'] as num?)?.toDouble(),
      participantCount: count,
    );
  }
}

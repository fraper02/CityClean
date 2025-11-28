class Event {

  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final DateTime startDateTime;
  final DateTime endDateTime;

  // Campo immagine attivo. Mappato su 'immagine_url'.
  // TODO: Aggiungere campo imageUrl al database (NOTNull)
  final String imageUrl;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.startDateTime,
    required this.endDateTime,
    required this.imageUrl,
  });

  // --- SERIALIZZAZIONE (Supabase <-> Flutter) ---

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['idEvento'],
      title: json['titolo'],
      description: json['descrizione'],
      location: json['località'],
      category: json['categoria'],

      startDateTime: DateTime.parse(json['dataOraInizio']),
      endDateTime: DateTime.parse(json['dataOraFine']),

      imageUrl: json['immagine_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEvento': id,
      'titolo': title,
      'descrizione': description,
      'località': location,
      'categoria': category,
      'dataOraInizio': startDateTime.toIso8601String(),
      'dataOraFine': endDateTime.toIso8601String(),
      'immagine_url': imageUrl,
    };
  }
}
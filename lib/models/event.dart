class Event {

  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final DateTime startDateTime;
  final DateTime endDateTime;
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
    // CORREZIONE: Usa la chiave esatta 'immagine' fornita dall'utente
    final imageUrlFromDb = json['immagine'] as String?;

    return Event(
      // CORREZIONE: Utilizzo delle chiavi esatte fornite dall'utente
      id: json['idevento']?.toString() ?? '', 
      title: json['titolo'] as String? ?? 'Titolo non disponibile', 
      description: json['descrizione'] as String? ?? 'Descrizione non disponibile', 
      location: json['localita'] as String? ?? 'Luogo non disponibile',
      category: json['categoria'] as String? ?? 'Nessuna categoria', 

      // CORREZIONE: Chiavi esatte 'dataorainizio' e 'dataorafine'
      startDateTime: json['dataorainizio'] != null
          ? DateTime.parse(json['dataorainizio'] as String)
          : DateTime.now(),
      endDateTime: json['dataorafine'] != null
          ? DateTime.parse(json['dataorafine'] as String)
          : DateTime.now(),

      imageUrl: (imageUrlFromDb == null || imageUrlFromDb.isEmpty)
          ? 'https://placehold.co/600x400/2E7D32/FFFFFF?text=CityClean' // Placeholder
          : imageUrlFromDb,
    );
  }

  // CORREZIONE: Aggiornato toJson per usare le chiavi esatte del DB
  Map<String, dynamic> toJson() {
    return {
      'idevento': id,
      'titolo': title,
      'descrizione': description,
      'localita': location,
      'categoria': category,
      'dataorainizio': startDateTime.toIso8601String(),
      'dataorafine': endDateTime.toIso8601String(),
      'immagine': imageUrl,
    };
  }
}

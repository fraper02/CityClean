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
    // Legge l'URL dell'immagine in modo sicuro, usando la convenzione snake_case
    final imageUrlFromDb = json['immagine'] as String?;

    return Event(
      // MODIFICA: Utilizzo di chiavi snake_case, standard per Supabase
      id: json['idevento'] as String? ?? '',
      title: json['titolo'] as String? ?? 'Titolo non disponibile', 
      description: json['descrizione'] as String? ?? 'Descrizione non disponibile', 
      location: json['localita'] as String? ?? 'Luogo non disponibile',
      category: json['categoria'] as String? ?? 'Nessuna categoria', 

      // MODIFICA: Chiavi snake_case per le date per matchare il DB
      startDateTime: json['dataorainizio'] != null
          ? DateTime.parse(json['dataorainizio'])
          : DateTime.now(), // Fallback solo se il dato è davvero nullo
      endDateTime: json['dataorafine'] != null
          ? DateTime.parse(json['dataorafine'])
          : DateTime.now(),

      imageUrl: (imageUrlFromDb == null || imageUrlFromDb.isEmpty)
          ? 'https://placehold.co/600x400/2E7D32/FFFFFF?text=CityClean' // URL del placeholder
          : imageUrlFromDb,
    );
  }

  // MODIFICA: Aggiornato anche toJson per coerenza
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

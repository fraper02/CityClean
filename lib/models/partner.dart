class Partner {
  final String idpartner;
  final String nome;
  final String? descrizione;
  final String? link;
  // Campi aggiunti per la geolocalizzazione
  final String? indirizzo;
  final double? latitudine;
  final double? longitudine;

  Partner({
    required this.idpartner,
    required this.nome,
    this.descrizione,
    this.link,
    this.indirizzo,
    this.latitudine,
    this.longitudine,
  });

  factory Partner.fromMap(Map<String, dynamic> map) {
    // Helper per coordinate sicure
    double? parseCoord(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value.replaceAll(',', '.'));
      return null;
    }

    return Partner(
      idpartner: map['idpartner']?.toString() ?? '',
      nome: map['nome'] ?? 'Senza Nome',
      descrizione: map['descrizione'],
      link: map['link'] ?? map['link'], // Gestisce vari naming conventions
      indirizzo: map['indirizzo'],
      latitudine: parseCoord(map['latitudine']),
      longitudine: parseCoord(map['longitudine']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idpartner': idpartner,
      'nome': nome,
      'descrizione': descrizione,
      'link': link, // Assumiamo che la colonna DB si chiami 'sito_web' o 'link'
      'indirizzo': indirizzo,
      'latitudine': latitudine,
      'longitudine': longitudine,
    };
  }

  // Alias per compatibilità se il tuo codice usa toJson
  Map<String, dynamic> toJson() => toMap();
}
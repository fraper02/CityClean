class PuntoDiRaccolta {

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String type;

  PuntoDiRaccolta({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
  });

  // --- SERIALIZZAZIONE (Supabase <-> Flutter) ---

  factory PuntoDiRaccolta.fromJson(Map<String, dynamic> json) {
    return PuntoDiRaccolta(
      id: json['idPuntoDiRaccolta'],
      name: json['nome'],
      address: json['indirizzo'],
      latitude: (json['latitudine'] as num).toDouble(),
      longitude: (json['longitudine'] as num).toDouble(),

      type: json['tipologia'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPuntoDiRaccolta': id,
      'nome': name,
      'indirizzo': address,
      'latitudine': latitude,
      'longitudine': longitude,
      'tipologia': type,
    };
  }
}
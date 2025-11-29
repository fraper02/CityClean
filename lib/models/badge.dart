class Badge {
  final String id;
  final String nome;
  final String descrizione;
  final String urlIcona;
  final String criterioSblocco;

  Badge({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.urlIcona,
    required this.criterioSblocco,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      nome: json['nome'],
      descrizione: json['descrizione'],
      // DB camelCase: urlIcona
      urlIcona: json['urlIcona'] ?? '',
      // DB camelCase: criterioSblocco
      criterioSblocco: json['criterioSblocco'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descrizione': descrizione,
      'urlIcona': urlIcona,
      'criterioSblocco': criterioSblocco,
    };
  }
}
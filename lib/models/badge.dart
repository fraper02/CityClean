class Badge {
  final String id;
  final String nome;
  final String descrizione;
  final String urlIcona;
  final String criterioSblocco;
  final bool isUnlocked;

  Badge({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.urlIcona,
    required this.criterioSblocco,
    this.isUnlocked = false,
  });

  Badge copyWith({bool? isUnlocked}) {
    return Badge(
      id: id,
      nome: nome,
      descrizione: descrizione,
      urlIcona: urlIcona,
      criterioSblocco: criterioSblocco,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['idbadge'],
      nome: json['nome'],
      descrizione: json['descrizione'],
      urlIcona: json['iconaurl'] ?? '',
      criterioSblocco: json['criteriosblocco'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idbadge': id,
      'nome': nome,
      'descrizione': descrizione,
      'iconaurl': urlIcona,
      'criteriosblocco': criterioSblocco,
    };
  }
}

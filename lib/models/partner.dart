class Partner {
  final String id;
  final String nome;
  final String? descrizione;
  final String? link;

  Partner({
    required this.id,
    required this.nome,
    this.descrizione,
    this.link,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['idpartner'] as String,
      nome: json['nome'] as String? ?? 'N/A',
      descrizione: json['descrizione'] as String?,
      link: json['link'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idpartner': id,
      'nome': nome,
      'descrizione': descrizione,
      'link': link,
    };
  }
}

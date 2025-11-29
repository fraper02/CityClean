class Shop {
  final String id;
  final String nome;
  final String cognome;
  final String link;

  Shop({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.link,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'],
      nome: json['nome'],
      cognome: json['cognome'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cognome': cognome,
      'link': link,
    };
  }
}
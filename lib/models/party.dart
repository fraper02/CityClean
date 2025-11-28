class Party {
  final String id;
  final String nome;
  final String idCreatore;
  final int maxCapienza;
  final List<String> idMembri;

  Party({
    required this.id,
    required this.nome,
    required this.idCreatore,
    required this.maxCapienza,
    required this.idMembri,
  });

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json['id'],
      nome: json['nome'],
      // DB camelCase: idCreatore
      idCreatore: json['idCreatore'],
      // DB camelCase: maxCapienza
      maxCapienza: json['maxCapienza'],
      // DB camelCase: idMembri
      idMembri: List<String>.from(json['idMembri'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'idCreatore': idCreatore,
      'maxCapienza': maxCapienza,
      'idMembri': idMembri,
    };
  }
}
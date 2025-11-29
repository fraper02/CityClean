class Prize {
  final String id;
  final String nome;
  final String descrizione;
  final int costoPunti;
  final int quantitaDisponibile;
  final String idPartner;

  Prize({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.costoPunti,
    required this.quantitaDisponibile,
    required this.idPartner,
  });

  factory Prize.fromJson(Map<String, dynamic> json) {
    return Prize(
      id: json['id'],
      nome: json['nome'],
      descrizione: json['descrizione'],
      // DB camelCase
      costoPunti: json['costoPunti'],
      quantitaDisponibile: json['quantitadisponibile'],
      idPartner: json['idPartner'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descrizione': descrizione,
      'costoPunti': costoPunti,
      'quantitadisponibile': quantitaDisponibile,
      'idPartner': idPartner,
    };
  }
}
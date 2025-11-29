class Prize {
  // Uso nomi standard Dart per le variabili interne
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
      // Mappatura: DB (chiave stringa) -> Dart (variabile)
      id: json['idpremio'] ?? '',
      nome: json['nome'] ?? '',
      descrizione: json['descrizione'] ?? '',
      costoPunti: json['costopunti'] is int
          ? json['costopunti']
          : int.tryParse(json['costopunti'].toString()) ?? 0,

      // SOLUZIONE: Corretto il nome della colonna per leggere dal DB.
      quantitaDisponibile: json['quantitadisponibile'] is int
          ? json['quantitadisponibile']
          : int.tryParse(json['quantitadisponibile'].toString()) ?? 0,

      idPartner: json['idpartner'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idpremio': id,
      'nome': nome,
      'descrizione': descrizione,
      'costopunti': costoPunti,
      // Corretto anche qui per coerenza
      'quantitadisponibile': quantitaDisponibile,
      'idpartner': idPartner,
    };
  }
}
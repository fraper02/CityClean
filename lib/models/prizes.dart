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
      id: json['idpremio'] ?? '', // DB: idpremio
      nome: json['nome'] ?? '',
      descrizione: json['descrizione'] ?? '',
      costoPunti: json['costopunti'] is int
          ? json['costopunti']
          : int.tryParse(json['costopunti'].toString()) ?? 0, // DB: costopunti

      // ATTENZIONE: Nel tuo messaggio hai scritto "quantitadiponibile" (senza la 's').
      // Se nel DB è scritto corretto ("quantitadisponibile"), aggiungi la 's' qui sotto.
      quantitaDisponibile: json['quantitadiponibile'] is int
          ? json['quantitadiponibile']
          : int.tryParse(json['quantitadiponibile'].toString()) ?? 0,

      idPartner: json['idpartner'] ?? '', // DB: idpartner
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idpremio': id,
      'nome': nome,
      'descrizione': descrizione,
      'costopunti': costoPunti,
      'quantitadiponibile': quantitaDisponibile, // Stesso nome colonna del DB
      'idpartner': idPartner,
    };
  }
}
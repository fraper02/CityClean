class Obiettivo {
  final String id;
  final String nome;
  final String descrizione;
  final bool isTempo;
  final DateTime? dataInizio;
  final DateTime? dataFine;
  final int puntiRicompensa;

  // Campi per lo stato dell'utente
  final bool isConseguito;
  final DateTime? dataCompletamento;
  final int? puntiGuadagnati;

  Obiettivo({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.isTempo,
    this.dataInizio,
    this.dataFine,
    required this.puntiRicompensa,
    // Dati specifici dell'utente
    this.isConseguito = false,
    this.dataCompletamento,
    this.puntiGuadagnati,
  });

  factory Obiettivo.fromJson(Map<String, dynamic> json) {
    final conseguimentoData = json['conseguimento_obiettivo'];

    return Obiettivo(
      id: json['idobiettivo'] ?? '',
      nome: json['nome'] ?? 'Obiettivo sconosciuto',
      descrizione: json['descrizione'] ?? 'Nessuna descrizione.',
      isTempo: json['tempo'] ?? false,
      dataInizio: json['datainizio'] != null ? DateTime.parse(json['datainizio']) : null,
      dataFine: json['datafine'] != null ? DateTime.parse(json['datafine']) : null,
      puntiRicompensa: json['punti_ricompensa'] ?? 0,
      
      // Se la join con `conseguimento_obiettivo` ha prodotto un risultato, l'obiettivo è conseguito
      isConseguito: conseguimentoData != null && (conseguimentoData as List).isNotEmpty,
      dataCompletamento: (conseguimentoData != null && (conseguimentoData as List).isNotEmpty)
          ? DateTime.parse(conseguimentoData[0]['data_completamento'])
          : null,
      puntiGuadagnati: (conseguimentoData != null && (conseguimentoData as List).isNotEmpty)
          ? conseguimentoData[0]['punti_guadagnati']
          : null,
    );
  }
}

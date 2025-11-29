class Task {
  final String id;
  final String nome;
  final String cognome;
  final bool tempo;
  final DateTime dataInizio;
  final DateTime dataFine;
  final int sogliaCompletamento;

  Task({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.tempo,
    required this.dataInizio,
    required this.dataFine,
    required this.sogliaCompletamento,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      nome: json['nome'],
      cognome: json['cognome'],
      tempo: json['tempo'] ?? false,
      // DB camelCase
      dataInizio: DateTime.parse(json['dataInizio']),
      dataFine: DateTime.parse(json['dataFine']),
      sogliaCompletamento: json['sogliaCompletamento'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cognome': cognome,
      'tempo': tempo,
      'dataInizio': dataInizio.toIso8601String(),
      'dataFine': dataFine.toIso8601String(),
      'sogliaCompletamento': sogliaCompletamento,
    };
  }
}
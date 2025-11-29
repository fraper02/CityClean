class Report {
  final String id;
  final double latitude;
  final double longitude;
  final String livelloInquinamento;
  final String tipoInquinante;
  final DateTime ultimoAggiornamento;
  final String fonteDato;
  final String stato;

  Report({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.livelloInquinamento,
    required this.tipoInquinante,
    required this.ultimoAggiornamento,
    required this.fonteDato,
    required this.stato,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      latitude: (json['latitudine'] as num).toDouble(),
      longitude: (json['longitudine'] as num).toDouble(),
      // DB camelCase
      livelloInquinamento: json['livelloInquinamento'],
      tipoInquinante: json['tipoInquinante'],
      ultimoAggiornamento: DateTime.parse(json['ultimoAggiornamento']),
      fonteDato: json['fonteDato'],
      stato: json['stato'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitudine': latitude,
      'longitudine': longitude,
      'livelloInquinamento': livelloInquinamento,
      'tipoInquinante': tipoInquinante,
      'ultimoAggiornamento': ultimoAggiornamento.toIso8601String(),
      'fonteDato': fonteDato,
      'stato': stato,
    };
  }
}
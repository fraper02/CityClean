class ValoreRifiuto {
  final int id;
  final String tipoRifiuto;
  final double valoreRifiuto;

  ValoreRifiuto({
    required this.id,
    required this.tipoRifiuto,
    required this.valoreRifiuto,
  });

  factory ValoreRifiuto.fromJson(Map<String, dynamic> json) {
    return ValoreRifiuto(
      id: json['id'] as int,
      // Legge dal nuovo nome della colonna `tipo_rifiuto`
      tipoRifiuto: json['tipo_rifiuto'] as String,
      // Legge dal nuovo nome della colonna `valore_rifiuto` e lo converte
      valoreRifiuto: (json['valore_rifiuto'] as num).toDouble(),
    );
  }
}

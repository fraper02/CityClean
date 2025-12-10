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
      id: json['id'],
      tipoRifiuto: json['tipoRifiuto'],
      valoreRifiuto: (json['valoreRifiuto'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipoRifiuto': tipoRifiuto,
      'valoreRifiuto': valoreRifiuto,
    };
  }
}
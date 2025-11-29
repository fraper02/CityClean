class WasteImage {
  final String id;
  final String categoria;
  final String contenitoreCorretto;
  final int valoreInPunti;

  WasteImage({
    required this.id,
    required this.categoria,
    required this.contenitoreCorretto,
    required this.valoreInPunti,
  });

  factory WasteImage.fromJson(Map<String, dynamic> json) {
    return WasteImage(
      id: json['id'],
      categoria: json['categoria'],
      // DB camelCase
      contenitoreCorretto: json['contenitoreCorretto'],
      valoreInPunti: json['valoreInPunti'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoria': categoria,
      'contenitoreCorretto': contenitoreCorretto,
      'valoreInPunti': valoreInPunti,
    };
  }
}
class WasteBin {
  final String wasteLabel;
  final String binName;
  final String binColorHex;
  final String binIconName;

  WasteBin({
    required this.wasteLabel,
    required this.binName,
    required this.binColorHex,
    required this.binIconName,
  });

  factory WasteBin.fromMap(Map<String, dynamic> map) {
    return WasteBin(
      wasteLabel: map['waste_label'] as String,
      binName: map['bin_name'] as String,
      binColorHex: map['bin_color_hex'] as String,
      binIconName: map['bin_icon_name'] as String,
    );
  }
}

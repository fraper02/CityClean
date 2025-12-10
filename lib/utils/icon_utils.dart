import 'package:flutter/material.dart';

class IconUtils {
  static final Map<String, IconData> _icons = {
    'recycling': Icons.recycling,
    'description': Icons.description,
    'wine_bar': Icons.wine_bar,
    'eco': Icons.eco,
    'electrical_services': Icons.electrical_services,
    'delete': Icons.delete,
    // Aggiungi altre icone qui se necessario
  };

  static IconData getIconData(String iconName) {
    return _icons[iconName.toLowerCase()] ?? Icons.help; // Ritorna un'icona di default se non trovata
  }
}

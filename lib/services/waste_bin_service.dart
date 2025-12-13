import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bin_info.dart';
import '../utils/icon_utils.dart';

class WasteBinService {
  final SupabaseClient _client = Supabase.instance.client;
  List<Map<String, dynamic>>? _binRules;

  final BinInfo _fallbackBin = BinInfo(
    binName: 'INDIFFERENZIATO / SECCO',
    color: Colors.grey[800]!,
    icon: Icons.delete_outline,
  );

  // Carica e memorizza in cache le regole dal DB
  Future<void> _loadAndCacheRules() async {
    if (_binRules == null) {
      try {
        final data = await _client.rpc('get_waste_bin_rules');
        _binRules = List<Map<String, dynamic>>.from(data);
      } catch (e) {
        debugPrint("Errore caricamento regole cassonetti: $e");
        _binRules = [];
      }
    }
  }

  // Trova le info del cassonetto per una data etichetta
  Future<BinInfo> getBinInfoForLabel(String wasteLabel) async {
    await _loadAndCacheRules();

    if (_binRules != null) {
      final lowerCaseWasteLabel = wasteLabel.trim().toLowerCase();

      for (var rule in _binRules!) {
        final lowerCaseRuleLabel = (rule['waste_label'] as String? ?? '').trim().toLowerCase();
        if (lowerCaseRuleLabel.isEmpty) continue;

        if (lowerCaseWasteLabel == lowerCaseRuleLabel) {
          return _createBinInfoFromRule(rule);
        }
      }
    }

    return _fallbackBin;
  }

  // Converte una riga del DB in un oggetto BinInfo
  BinInfo _createBinInfoFromRule(Map<String, dynamic> rule) {
    try {
      // Recuperiamo l'etichetta per decidere l'icona specifica
      final String label = (rule['waste_label'] as String? ?? '').toLowerCase().trim();

      // 1. GESTIONE ICONE SPECIFICHE (Override Estetico)
      // Qui assegniamo le icone "belle" ignorando momentaneamente quella del DB se presente
      IconData icon;

      switch (label) {
      // ELETTRONICA E SPECIALI
        case 'light bulb':
        case 'bulb':
          icon = Icons.lightbulb;
          break;
        case 'battery':
        case 'batteries':
          icon = Icons.battery_alert;
          break;
        case 'e-waste':
        case 'computer':
        case 'phone':
          icon = Icons.phonelink_setup;
          break;

      // VETRO
        case 'glass':
        case 'bottle':
        case 'glass bottle':
        case 'wine bottle':
          icon = Icons.wine_bar;
          break;

      // PLASTICA E METALLI
        case 'plastic':
        case 'plastic bottle':
          icon = Icons.local_drink;
          break;
        case 'can':
        case 'metal':
        case 'aluminium':
          icon = Icons.takeout_dining; // Oramai spesso usata per lattine/cibo
          break;

      // CARTA
        case 'paper':
        case 'cardboard':
        case 'newspaper':
        case 'magazine':
          icon = Icons.newspaper;
          break;
        case 'book':
          icon = Icons.menu_book;
          break;

      // ORGANICO
        case 'organic':
        case 'food':
        case 'apple':
        case 'banana':
        case 'fruit':
        case 'vegetable':
          icon = Icons.eco;
          break;

      // INGOMBRANTI / SPECIALI
        case 'automobile waste':
        case 'tire':
        case 'wheel':
          icon = Icons.directions_car;
          break;
        case 'clothes':
        case 'cloth':
        case 'shoe':
        case 'shoes':
          icon = Icons.checkroom;
          break;

      // DEFAULT: Se non è nella lista sopra, usa quella definita nel DB tramite IconUtils
        default:
          icon = IconUtils.getIconData(rule['bin_icon_name'] ?? 'delete');
      }

      // 2. GESTIONE COLORE
      final color = _hexToColor(rule['bin_color_hex'] ?? '#808080');

      return BinInfo(
        binName: rule['bin_name'] ?? 'Indifferenziato',
        color: color,
        icon: icon,
      );
    } catch (e) {
      debugPrint("Errore conversione regola: $e");
      return _fallbackBin;
    }
  }

  Color _hexToColor(String code) {
    try {
      // Gestisce sia '#FF0000' che 'FF0000'
      final hexCode = code.replaceAll('#', '');
      return Color(int.parse(hexCode, radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }
}
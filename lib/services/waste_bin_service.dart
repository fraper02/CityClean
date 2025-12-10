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
    icon: Icons.delete,
  );

  // Carica e memorizza in cache le regole dal DB
  Future<void> _loadAndCacheRules() async {
    if (_binRules == null) {
      try {
        // CORREZIONE DEFINITIVA: Usa la chiamata RPC, che è il metodo corretto e stabile.
        final data = await _client.rpc('get_waste_bin_rules');
        _binRules = List<Map<String, dynamic>>.from(data);

      } catch (e) {
        debugPrint("Errore caricamento regole cassonetti: $e");
        _binRules = []; // Evita tentativi ripetuti in caso di errore
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
        if (lowerCaseRuleLabel.isEmpty) continue; // Salta regole vuote

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
      final color = _hexToColor(rule['bin_color_hex'] ?? '#808080');
      final icon = IconUtils.getIconData(rule['bin_icon_name'] ?? 'delete');
      
      return BinInfo(
        binName: rule['bin_name'] ?? 'Indifferenziato',
        color: color,
        icon: icon,
      );
    } catch (e) {
      debugPrint("Errore conversione regola: $e");
      return _fallbackBin; // In caso di errore in una regola, usa il fallback
    }
  }

  // Converte un colore esadecimale (es. #FF8F00) in un oggetto Color
  Color _hexToColor(String code) {
    try {
      return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey; // Fallback color
    }
  }
}

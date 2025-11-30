// lib/models/prizes.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class Prize {
  // ... (proprietà e costruttore invariati) ...
  final String id;
  final String nome;
  final String descrizione;
  final int costoPunti;
  final int quantitaDisponibile;
  final String idPartner;

  Prize({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.costoPunti,
    required this.quantitaDisponibile,
    required this.idPartner,
  });


  // ... (fromJson e toJson invariati) ...
  factory Prize.fromJson(Map<String, dynamic> json) {
    return Prize(
      id: json['idpremio'] ?? '',
      nome: json['nome'] ?? '',
      descrizione: json['descrizione'] ?? '',
      costoPunti: json['costopunti'] is int
          ? json['costopunti']
          : int.tryParse(json['costopunti'].toString()) ?? 0,
      quantitaDisponibile: json['quantitadisponibile'] is int
          ? json['quantitadisponibile']
          : int.tryParse(json['quantitadisponibile'].toString()) ?? 0,
      idPartner: json['idpartner'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idpremio': id,
      'nome': nome,
      'descrizione': descrizione,
      'costopunti': costoPunti,
      'quantitadisponibile': quantitaDisponibile,
      'idpartner': idPartner,
    };
  }

  // --- LOGICA DAO INTEGRATA NEL MODELLO ---
  static final _supabase = Supabase.instance.client;

  /// Recupera tutti i premi disponibili.
  static Future<List<Prize>> fetchAll() async {
    final response = await _supabase.from('premio').select();
    return (response as List).map((item) => Prize.fromJson(item)).toList();
  }

  // ---------- CORREZIONE QUI ----------
  /// Aggiorna la quantità di un premio.
  static Future<void> updateQuantity(String prizeId, int newQuantity) async {
    await _supabase
        .from('premio')
        .update({'quantitadisponibile': newQuantity})
        .eq('idpremio', prizeId);
  }
// ------------------------------------
}

import 'package:cityclean/models/partner.dart'; // Importa il modello Partner
import 'package:supabase_flutter/supabase_flutter.dart';

class Prize {
  final String id;
  final String nome;
  final String descrizione;
  final int costoPunti;
  final int quantitaDisponibile;
  final String idPartner;
  final Partner? partner; // Campo per contenere l'oggetto Partner

  Prize({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.costoPunti,
    required this.quantitaDisponibile,
    required this.idPartner,
    this.partner,
  });

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
      // CORREZIONE: Qui usavamo Partner.fromJson, ora usiamo Partner.fromMap
      partner: json.containsKey('partner') && json['partner'] != null
          ? Partner.fromMap(json['partner'])
          : null,
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

  static final _supabase = Supabase.instance.client;

  static Future<List<Prize>> fetchAll() async {
    // La join '*, partner(*)' è fondamentale per popolare il campo partner
    final response = await _supabase.from('premio').select('*, partner:idpartner(*)');
    return (response as List).map((item) => Prize.fromJson(item)).toList();
  }
}
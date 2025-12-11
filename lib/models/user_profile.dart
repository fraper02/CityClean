import 'package:cityclean/main.dart';
import 'package:flutter/foundation.dart';

class UserProfile with ChangeNotifier {
  String id;
  String nome;
  String? cognome;
  String email;
  int saldoPunti;
  String codiceReferral;
  String? fotoProfilo;
  bool isAdmin;
  DateTime? dataDiNascita;
  String? idBadgeTitolo;
  String? titolo;

  final int conferimentiCount;
  final int eventsCount;

  UserProfile({
    required this.id,
    required this.nome,
    this.cognome,
    required this.email,
    required this.saldoPunti,
    required this.codiceReferral,
    this.fotoProfilo,
    required this.isAdmin,
    this.dataDiNascita,
    this.idBadgeTitolo,
    this.titolo, 
    this.conferimentiCount = 0,
    this.eventsCount = 0,
  });

  static Future<int> getPoints(String userId) async {
    try {
      final data = await supabase.from('utente').select('saldopunti').eq('idutente', userId).single();
      return (data['saldopunti'] as num?)?.toInt() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['idutente'] as String,
      nome: json['nome'] as String? ?? 'Utente',
      cognome: json['cognome'] as String?,
      email: json['email'] as String? ?? 'N/A',
      saldoPunti: (json['saldopunti'] as num?)?.toInt() ?? 0,
      codiceReferral: json['codicereferral'] as String? ?? 'N/A',
      fotoProfilo: json['fotoprofilo'] as String?,
      isAdmin: json['isadmin'] as bool? ?? false,
      dataDiNascita: json['datadinascita'] != null ? DateTime.tryParse(json['datadinascita']) : null,
      idBadgeTitolo: json['id_badge_titolo'] as String?,
      titolo: json['titolo_nome'] as String?,
      conferimentiCount: (json['conferimenti_count'] as num?)?.toInt() ?? 0,
      eventsCount: (json['events_count'] as num?)?.toInt() ?? 0,
    );
  }

  // NUOVO METODO: Converte l'oggetto in una mappa JSON
  Map<String, dynamic> toJson() {
    return {
      'idutente': id, // Usa la chiave corretta per coerenza con fromJson
      'id': id, // Aggiungo anche 'id' per coerenza con il codice che lo usa
      'nome': nome,
      'cognome': cognome,
      'email': email,
      'saldopunti': saldoPunti,
      'codicereferral': codiceReferral,
      'fotoprofilo': fotoProfilo,
      'isadmin': isAdmin,
      'datadinascita': dataDiNascita?.toIso8601String(),
      'id_badge_titolo': idBadgeTitolo,
      'titolo_nome': titolo,
      'conferimenti_count': conferimentiCount,
      'events_count': eventsCount,
    };
  }

  UserProfile withStats({required int conferimenti, required int events}) {
    return UserProfile(
      id: id,
      nome: nome,
      cognome: cognome,
      email: email,
      saldoPunti: saldoPunti,
      codiceReferral: codiceReferral,
      fotoProfilo: fotoProfilo,
      isAdmin: isAdmin,
      dataDiNascita: dataDiNascita,
      idBadgeTitolo: idBadgeTitolo,
      titolo: titolo,
      conferimentiCount: conferimenti,
      eventsCount: events,
    );
  }
}

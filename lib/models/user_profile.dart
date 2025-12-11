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
  String? titolo; // Questo è il nome del badge/titolo

  // Campi per le statistiche
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

  // Metodo statico per compatibilità
  static Future<int> getPoints(String userId) async {
    try {
      final data = await supabase
          .from('utente')
          .select('saldopunti')
          .eq('idutente', userId)
          .single();
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
      // CORREZIONE: Legge il nome del titolo dalla chiave corretta usata nel service
      titolo: json['titolo_nome'] as String?,
      conferimentiCount: (json['conferimenti_count'] as num?)?.toInt() ?? 0,
      eventsCount: (json['events_count'] as num?)?.toInt() ?? 0,
    );
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

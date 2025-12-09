// 1. AGGIUNTO QUESTO IMPORT PER debugPrint
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String nome;
  final String? cognome;
  final String email;
  final int saldoPunti;
  final String codiceReferral;
  final String? fotoProfilo;
  final bool isAdmin;
  final String? idBadgeTitolo; // ID del badge scelto come titolo
  final String? titolo;        // Nome del badge (verrà popolato dal service)

  UserProfile({
    required this.id,
    required this.nome,
    this.cognome,
    required this.email,
    required this.saldoPunti,
    required this.codiceReferral,
    this.fotoProfilo,
    required this.isAdmin,
    this.idBadgeTitolo,
    this.titolo,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['idutente'] as String? ?? '',
      nome: json['nome'] as String? ?? 'Nome utente',
      cognome: json['cognome'] as String?,
      email: json['email'] as String? ?? '',
      saldoPunti: json['saldopunti'] as int? ?? 0,
      codiceReferral: json['codicereferral'] as String? ?? '',
      fotoProfilo: json['fotoprofilo'] as String?,
      isAdmin: json['isadmin'] as bool? ?? false,
      idBadgeTitolo: json['id_badge_titolo'] as String?,
      // Questo campo viene aggiunto dinamicamente dal service
      titolo: json['titolo_nome'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idutente': id,
      'nome': nome,
      'cognome': cognome,
      'email': email,
      'saldopunti': saldoPunti,
      'codicereferral': codiceReferral,
      'fotoprofilo': fotoProfilo,
      'isadmin': isAdmin,
      'id_badge_titolo': idBadgeTitolo,
    };
  }

  // Questi metodi DAO rimangono per compatibilità con altre parti dell'app
  static final _supabase = Supabase.instance.client;
  static const _tableName = 'utente';

  static Future<int> getPoints(String userId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('saldopunti')
          .eq('idutente', userId)
          .single();
      return response['saldopunti'] as int? ?? 0;
    } catch (e) {
      // 2. SOSTITUITO print CON debugPrint
      debugPrint("ERRORE CARICAMENTO PUNTI: $e");
      return 0;
    }
  }

  static Future<void> updatePoints(String userId, int newPoints) async {
    await _supabase
        .from(_tableName)
        .update({'saldopunti': newPoints})
        .eq('idutente', userId);
  }
}
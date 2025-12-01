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

  UserProfile({
    required this.id,
    required this.nome,
    this.cognome,
    required this.email,
    required this.saldoPunti,
    required this.codiceReferral,
    this.fotoProfilo,
    required this.isAdmin,
  });

  // Converte un oggetto JSON (dal DB) in un'istanza di UserProfile
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      // Assicurati che i nomi delle chiavi qui corrispondano esattamente
      // a quelli delle colonne nel tuo database Supabase.
      id: json['idutente'] as String? ?? '', 
      nome: json['nome'] as String? ?? 'Nome utente',
      cognome: json['cognome'] as String?, // Assegna null se non presente
      email: json['email'] as String? ?? '',
      saldoPunti: json['saldopunti'] as int? ?? 0,
      codiceReferral: json['codicereferral'] as String? ?? '',
      fotoProfilo: json['fotoprofilo'] as String?, // Assegna null se non presente
      isAdmin: json['isadmin'] as bool? ?? false,
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
      };
    }

  // --- METODI STATICI PER INTERAGIRE CON IL DATABASE ---
  static final _supabase = Supabase.instance.client;
  static const _tableName = 'utente'; // Nome della tabella centralizzato

  /// Recupera i punti per un dato utente.
  static Future<int> getPoints(String userId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('saldopunti')
          .eq('idutente', userId)
          .single();
      return response['saldopunti'] as int? ?? 0;
    } catch (e) {
      // Gestisce l'errore se l'utente non viene trovato o c'è un altro problema
      return 0;
    }
  }

  /// Aggiorna i punti di un utente.
  static Future<void> updatePoints(String userId, int newPoints) async {
    await _supabase
        .from(_tableName)
        .update({'saldopunti': newPoints})
        .eq('idutente', userId);
  }

}

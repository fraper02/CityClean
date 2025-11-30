// lib/models/userProfile.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  // --- Proprietà del modello (invariate) ---
  final String id;
  final String nome;
  final String cognome;
  final String email;
  final int saldoPunti;
  final String codiceReferral;
  final String? fotoProfilo;
  final bool isAdmin;

  UserProfile({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.saldoPunti,
    required this.codiceReferral,
    this.fotoProfilo,
    required this.isAdmin,
  });

  // --- Metodi di conversione (invariati) ---
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['idutente'], // Assicurati che i nomi colonne corrispondano!
      nome: json['nome'] ?? '',
      cognome: json['cognome'] ?? '',
      email: json['email'] ?? '',
      saldoPunti: json['saldopunti'] ?? 0,
      codiceReferral: json['codicereferral'] ?? '',
      fotoProfilo: json['fotoprofilo'],
      isAdmin: json['isadmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    // ... metodo toJson ...
    return { 'idutente': id, /* ...altri campi */ };
  }

  // --- LOGICA DAO INTEGRATA (METODI STATICI) ---
  static final _supabase = Supabase.instance.client;

  /// Recupera i punti per un dato utente.
  static Future<int> getPoints(String userId) async {
    final response = await _supabase
        .from('utente') // Usa il nome tabella corretto
        .select('saldopunti') // Usa il nome colonna corretto
        .eq('idutente', userId)
        .single();
    return response['saldopunti'] as int;
  }

  /// Aggiorna i punti di un utente.
  static Future<void> updatePoints(String userId, int newPoints) async {
    await _supabase
        .from('utente') // Usa il nome tabella corretto
        .update({'saldopunti': newPoints}) // Usa il nome colonna corretto
        .eq('idutente', userId);
  }
}

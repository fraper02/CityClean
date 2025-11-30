class UserProfile {
  final String id;
  final String nome;
  final String? cognome; // Può essere nullo
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

  // Metodo per convertire i dati che arrivano da Supabase (JSON)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['idutente'],
      nome: json['nome'] ?? '',
      cognome: json['cognome'], // Può essere null
      email: json['email'] ?? '',
      saldoPunti: json['saldopunti'] ?? 0, // Nome colonna corretto e valore di default
      codiceReferral: json['codicereferral'] ?? '', // Nome colonna corretto
      fotoProfilo: json['fotoprofilo'], // Nome colonna corretto
      isAdmin: json['is_admin'] ?? false, // Nome colonna corretto
    );
  }

  // Metodo per inviare i dati a Supabase
  Map<String, dynamic> toJson() {
    return {
      'idutente': id,
      'nome': nome,
      'cognome': cognome,
      'email': email,
      'saldopunti': saldoPunti,
      'codicereferral': codiceReferral,
      'fotoprofilo': fotoProfilo,
      'is_admin': isAdmin,
    };
  }
}

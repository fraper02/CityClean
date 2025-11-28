class UserProfile {
  final String id;
  final String nome;
  final String cognome;
  final String email;
  // ATTENZIONE: password (gestita da Supabase Auth) ??????
  final int saldoPunti;
  final String codiceReferral; // Corretto typo (una f, due r) ????
  final String? fotoProfilo;   // Messo '?' (nullable) perché può essere vuota all'inizio
  final bool isAdmin;

  UserProfile({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.saldoPunti,
    required this.codiceReferral,
    this.fotoProfilo, // Non è required
    required this.isAdmin,
  });

  // Metodo per convertire i dati che arrivano da Supabase (JSON)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'], // Assicurati che su Supabase la colonna si chiami 'id'
      nome: json['nome'],
      cognome: json['cognome'],
      email: json['email'],
      saldoPunti: json['saldoPunti'], // Nota lo snake_case tipico dei DB
      codiceReferral: json['codiceReferral'],
      fotoProfilo: json['fotoProfilo'], // Può essere null, va bene così
      isAdmin: json['isAdmin'] ?? false, // Se è null, di default è false
    );
  }

  // 2. Metodo per inviare i dati a Supabase
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cognome': cognome,
      'email': email,
      'saldoPunti': saldoPunti,
      'codiceReferral': codiceReferral,
      'fotoProfilo': fotoProfilo,
      'isAdmin': isAdmin,
    };
  }
}
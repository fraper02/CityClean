import '../models/userProfile.dart';

class UserService {
  // Simuliamo il recupero del profilo dal database
  Future<UserProfile> getCurrentUser() async {
    // Simula l'attesa della rete (es. chiamata a Supabase)
    await Future.delayed(const Duration(milliseconds: 800));

    // Restituisce un oggetto UserProfile "vero"
    return UserProfile(
      id: "user_123",
      nome: "Mario",
      cognome: "Rossi",
      email: "mario.rossi@email.com",
      saldoPunti: 350,
      codiceReferral: "MARIO24",
      fotoProfilo: null, // Metti un URL qui se vuoi provare l'immagine
      isAdmin: false,
    );
  }
}
import 'package:cityclean/models/userProfile.dart';
import 'package:cityclean/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  Future<UserProfile> getCurrentUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("Nessun utente loggato.");
    }

    try {
      final response = await supabase
          .from('utente')
          .select()
          .eq('idutente', user.id)
          .single();

      if (response.isEmpty) {
        throw Exception("Profilo utente non trovato nel database.");
      }

      // FIX: Mappiamo i nomi delle colonne dal DB ai campi del modello UserProfile
      return UserProfile.fromJson(response);

    } catch (e) {
      // In caso di errore (es. utente non trovato, errore di rete),
      // lanciamo un'eccezione che può essere gestita dalla UI.
      print("Errore nel recupero del profilo: $e");
      throw Exception("Impossibile caricare i dati del profilo.");
    }
  }
}

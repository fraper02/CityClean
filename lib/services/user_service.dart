import 'package:cityclean/models/badge.dart';
import 'package:cityclean/models/user_profile.dart';
import '../main.dart'; // Per la variabile globale supabase
import 'package:flutter/foundation.dart';

class UserService {

  // Ottiene il profilo utente e, separatamente, il nome del suo titolo
  Future<UserProfile> getCurrentUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("Nessun utente loggato.");
    }

    try {
      final userData = await supabase
          .from('utente')
          .select()
          .eq('idutente', user.id)
          .single();

      if (userData.isEmpty) {
        throw Exception("Profilo utente non trovato nel database.");
      }

      final String? badgeTitleId = userData['id_badge_titolo'] as String?;
      
      // Se l'utente ha un titolo, eseguiamo una seconda query sicura per ottenerne il nome
      if (badgeTitleId != null && badgeTitleId.isNotEmpty) {
        try {
          final badgeData = await supabase
              .from('badge')
              .select('nome')
              .eq('idbadge', badgeTitleId)
              .single();
          // Aggiungiamo dinamicamente il nome del titolo al JSON prima di creare l'oggetto
          userData['titolo_nome'] = badgeData['nome'];
        } catch (e) {
          // Se il badge non esiste più, il titolo sarà null, ma l'app non crasha
          debugPrint("Badge del titolo non trovato (ID: $badgeTitleId): $e");
        }
      }
      
      return UserProfile.fromJson(userData);

    } catch (e) {
      debugPrint("Errore nel recupero del profilo utente: $e");
      throw Exception("Impossibile caricare i dati del profilo.");
    }
  }

  // Ottiene la lista dei badge che l'utente ha sbloccato
  Future<List<Badge>> getUnlockedBadges() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato.");

    try {
      final response = await supabase
          .from('badge')
          .select('*, possesso_badge!inner(*)') // JOIN per filtrare solo i badge posseduti
          .eq('possesso_badge.idutente', user.id);
      
      return (response as List).map((item) => Badge.fromJson(item)).toList();

    } catch (e) {
      debugPrint("Errore nel recupero dei badge sbloccati: $e");
      throw Exception("Impossibile caricare i titoli disponibili.");
    }
  }

  // Aggiorna il badge scelto come titolo dall'utente
  Future<void> updateUserTitle(String newBadgeId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato.");

    try {
      await supabase
          .from('utente')
          .update({'id_badge_titolo': newBadgeId})
          .eq('idutente', user.id);
    } catch (e) {
      debugPrint("Errore nell'aggiornamento del titolo: $e");
      throw Exception("Impossibile aggiornare il titolo.");
    }
  }
}

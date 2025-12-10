// (foundation.dart serve per usare debugPrint)
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AggiungiPuntiModel {
  static final _supabase = Supabase.instance.client;

  static Future<bool> assegnaPunti(String userId, int puntiDaAggiungere) async {
    try {
      // 2. SOSTITUISCI TUTTI I 'print' CON 'debugPrint'
      debugPrint("Tentativo di aggiungere $puntiDaAggiungere punti all'utente $userId");

      // 1. Recupera i punti attuali
      final data = await _supabase
          .from('utente')
          .select('saldopunti')
          .eq('idutente', userId)
          .single();

      final int puntiAttuali = data['saldopunti'] as int? ?? 0;
      debugPrint("Punti attuali: $puntiAttuali");

      final int nuoviPunti = puntiAttuali + puntiDaAggiungere;

      // 2. Esegui l'update e chiedi di restituire la riga modificata
      final response = await _supabase
          .from('utente')
          .update({'saldopunti': nuoviPunti})
          .eq('idutente', userId)
          .select();

      debugPrint("Risposta Update: $response");

      if (response.isEmpty) {
        debugPrint("ERRORE: Nessuna riga modificata. Probabile blocco RLS.");
        return false;
      }

      return true;
    } catch (e) {
      debugPrint("ECCEZIONE CRITICA: $e");
      return false;
    }
  }
}
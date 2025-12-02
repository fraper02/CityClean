import 'package:supabase_flutter/supabase_flutter.dart';

class AggiungiPuntiModel {
  static final _supabase = Supabase.instance.client;

  static Future<bool> assegnaPunti(String userId, int puntiDaAggiungere) async {
    try {
      print("Tentativo di aggiungere $puntiDaAggiungere punti all'utente $userId");

      // 1. Recupera i punti attuali
      final data = await _supabase
          .from('utente')
          .select('saldopunti')
          .eq('idutente', userId)
          .single();

      final int puntiAttuali = data['saldopunti'] as int? ?? 0;
      print("Punti attuali: $puntiAttuali");

      final int nuoviPunti = puntiAttuali + puntiDaAggiungere;

      // 2. Esegui l'update e chiedi di restituire la riga modificata (.select())
      // Questo ci dirà se la riga è stata trovata e modificata
      final response = await _supabase
          .from('utente')
          .update({'saldopunti': nuoviPunti})
          .eq('idutente', userId)
          .select(); // <--- IMPORTANTE: Restituisce i dati aggiornati

      print("Risposta Update: $response");

      // Se la lista è vuota, significa che la RLS ha bloccato la scrittura o l'ID è errato
      if (response.isEmpty) {
        print("ERRORE: Nessuna riga modificata. Probabile blocco RLS.");
        return false;
      }

      return true;
    } catch (e) {
      print("ECCEZIONE CRITICA: $e");
      return false;
    }
  }
}
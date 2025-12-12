// (foundation.dart serve per usare debugPrint)
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AggiungiPuntiModel {
  static final _supabase = Supabase.instance.client;

  /// Aggiunge punti e CO2 al saldo dell'utente.
  /// Assicurati che la tabella 'utente' abbia la colonna 'peso_co2_totale'.
  static Future<bool> assegnaPunti(String userId, int puntiDaAggiungere, double co2DaAggiungere) async {
    try {
      debugPrint("Tentativo di aggiungere $puntiDaAggiungere punti e $co2DaAggiungere Kg CO2 all'utente $userId");

      // 1. Recupera i valori attuali (Punti e CO2)
      final data = await _supabase
          .from('utente')
          .select('saldopunti, peso_co2_totale') // Recupera anche la CO2
          .eq('idutente', userId)
          .single();

      final int puntiAttuali = data['saldopunti'] as int? ?? 0;
      // Gestione sicura del cast a double (supabase a volte ritorna int per numeri interi)
      final double co2Attuale = (data['peso_co2_totale'] as num?)?.toDouble() ?? 0.0;

      debugPrint("Stato Attuale -> Punti: $puntiAttuali, CO2: $co2Attuale");

      final int nuoviPunti = puntiAttuali + puntiDaAggiungere;
      final double nuovaCo2 = co2Attuale + co2DaAggiungere;

      // 2. Esegui l'update di entrambi i campi
      final response = await _supabase
          .from('utente')
          .update({
        'saldopunti': nuoviPunti,
        'peso_co2_totale': nuovaCo2,
      })
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

class ValoreRifiuto {
  final int id;
  final String tipoRifiuto;
  final double valoreRifiuto; // Punti
  final double pesoCo2;       // CO2 (Assicurati che nel DB la colonna si chiami 'peso_co2')

  ValoreRifiuto({
    required this.id,
    required this.tipoRifiuto,
    required this.valoreRifiuto,
    required this.pesoCo2,
  });

  factory ValoreRifiuto.fromJson(Map<String, dynamic> json) {
    return ValoreRifiuto(
      id: json['id'] as int? ?? 0,
      tipoRifiuto: json['tipo_rifiuto'] as String? ?? '',
      // Gestione sicura dei numeri (converte int in double se necessario)
      valoreRifiuto: (json['valore_rifiuto'] as num?)?.toDouble() ?? 0.0,
      // Qui leggiamo il valore fondamentale per il tuo calcolo
      pesoCo2: (json['peso_co2'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
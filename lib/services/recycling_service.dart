import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';
import '../models/map_models.dart';

class RecyclingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Recupera i punti dalla tabella 'punto_raccolta'
  Future<List<EcoPoint>> getRecyclingPoints() async {
    try {
      // Eseguiamo la query sulla tabella specificata
      final List<dynamic> response = await _supabase
          .from('punto_raccolta')
          .select('nome, indirizzo, latitudine, longitudine, tipologia');

      // Mappiamo i dati del DB nel modello EcoPoint
      return response.map((data) {
        // Gestione sicura dei double (a volte arrivano come int o stringhe dal DB)
        final double lat = (data['latitudine'] is int)
            ? (data['latitudine'] as int).toDouble()
            : data['latitudine'];

        final double lng = (data['longitudine'] is int)
            ? (data['longitudine'] as int).toDouble()
            : data['longitudine'];

        // Gestione tipologia: puoi personalizzare la logica qui
        // Es. se nel DB 'C' sta per Cestino, puoi fare un check.
        // Qui assumiamo che il DB contenga già il nome completo o una sigla.
        String tipo = data['tipologia'] ?? 'Generico';
        if (tipo.toUpperCase() == 'C') tipo = 'Cestino'; // Esempio di conversione

        return EcoPoint(
          name: data['nome'] ?? 'Punto di raccolta',
          location: LatLng(lat, lng),
          type: tipo, id: '',
          // Se EcoPoint ha altri campi nel tuo model, aggiungili qui o metti valori di default
        );
      }).toList();

    } catch (e) {
      print('Errore recupero punti raccolta: $e');
      return []; // Ritorna lista vuota in caso di errore per non bloccare la mappa
    }
  }
}
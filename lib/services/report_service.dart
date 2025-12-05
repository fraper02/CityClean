import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart'; // Per accedere a supabase client

class ReportService {
  
  // Helper per generare ID stringa casuale
  String _generateId({String prefix = 'id'}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return '${prefix}_${timestamp}_$random';
  }

  /// Carica un'immagine su Supabase Storage e crea il record nella tabella 'immagine'.
  /// Restituisce l'ID dell'immagine da usare nella segnalazione.
  Future<String> uploadImageAndGetId(File imageFile) async {
    try {
      // 1. Upload su Storage (Bucket 'immagini' ipotizzato)
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'segnalazioni/$fileName';
      
      // Nota: Assicurati che esista un bucket chiamato 'immagini' su Supabase
      // Se fallisce l'upload, controlla i permessi e il nome bucket.
      await supabase.storage.from('immagini').upload(storagePath, imageFile);
      
      final imageUrl = supabase.storage.from('immagini').getPublicUrl(storagePath);

      // 2. Inserimento nella tabella 'immagine' per ottenere l'ID valido (FK)
      // Ipotizzo che la tabella si chiami 'immagine' e abbia 'idimmagine' e 'url'.
      final newImageId = _generateId(prefix: 'img');
      
      await supabase.from('immagine').insert({
        'idimmagine': newImageId,
        'url': imageUrl,
        // Aggiungi altri campi se richiesti (es. data, tipo, ecc.)
      });

      return newImageId;

    } on StorageException catch (e) {
      debugPrint('ERRORE STORAGE [uploadImage]: ${e.message}');
      throw Exception('Errore caricamento foto: ${e.message}');
    } on PostgrestException catch (e) {
      debugPrint('ERRORE DB IMMAGINE [uploadImage]: ${e.message}');
      throw Exception('Errore salvataggio riferimento foto: ${e.message}');
    } catch (e) {
      debugPrint('ERRORE GENERICO [uploadImage]: $e');
      throw Exception('Errore upload immagine: $e');
    }
  }

  // TAB 1: Segnalazione Rapida -> Tabella 'segnalazione'
  Future<void> createReport({
    required String description, 
    required String wasteType, 
    required double latitude,
    required double longitude,
    required String userId,
    required String imageId, // Ora richiesto e passato dalla UI dopo l'upload
  }) async {
    try {
      final reportId = _generateId(prefix: 'rep');
      final fullDescription = "$wasteType - $description";

      await supabase.from('segnalazione').insert({
        'idsegnalazione': reportId,
        'idutente': userId,
        'idimmagine': imageId, // Qui usiamo l'ID valido appena creato
        'latitudine': latitude,
        'longitudine': longitude,
        'livelloinquinamento': 'Alto', 
        'tipoinquinamento': fullDescription.length > 255 
            ? fullDescription.substring(0, 255) 
            : fullDescription,
        'ultimoaggiornamento': DateTime.now().toIso8601String(),
        'fontedato': 'App Utente',
        'stato': 'Aperta',
      });
    } on PostgrestException catch (e) {
      debugPrint('ERRORE SUPABASE [createReport]: ${e.message}');
      throw Exception('Errore nel salvataggio segnalazione: ${e.message}');
    } catch (e) {
      debugPrint('ERRORE GENERICO [createReport]: $e');
      throw Exception('Errore sconosciuto: $e');
    }
  }

  // TAB 2: Evento Futuro -> Tabella 'evento'
  Future<void> createEvent({
    required String title,
    required String description,
    required String wasteType,
    required DateTime date,
    required double latitude,
    required double longitude,
    required String userId,
  }) async {
    try {
      await supabase.from('evento').insert({
        'titolo': title,
        'descrizione': description,
        'categoria': wasteType,
        'dataorainizio': date.toIso8601String(),
        'dataorafine': date.add(const Duration(hours: 3)).toIso8601String(),
        'localita': "Lat: $latitude, Lon: $longitude",
        'latitudine': latitude,
        'longitudine': longitude,
        'immagine': 'https://placehold.co/600x400/orange/white?text=Evento+CityClean',
      });
    } on PostgrestException catch (e) {
      debugPrint('ERRORE SUPABASE [createEvent]: ${e.message}');
      throw Exception('Errore nel salvataggio evento: ${e.message}');
    } catch (e) {
      debugPrint('ERRORE GENERICO [createEvent]: $e');
      throw Exception('Errore sconosciuto: $e');
    }
  }
}

import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart'; // Per accedere a supabase client
import '../services/notifiche.dart';


class ReportService {
  
  // Helper per generare ID stringa casuale
  String _generateId({String prefix = 'id'}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return '${prefix}_${timestamp}_$random';
  }

  /// Carica un'immagine su Supabase Storage e crea il record nella tabella 'immagine'.
  Future<String> uploadImageAndGetId(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'segnalazioni/$fileName';
      
      // FIX: Leggiamo i byte del file e usiamo uploadBinary per maggiore compatibilità
      final imageBytes = await imageFile.readAsBytes();
      await supabase.storage.from('immagini').uploadBinary(
        storagePath, 
        imageBytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          contentType: 'image/jpeg',
        ),
      );
      
      final imageUrl = supabase.storage.from('immagini').getPublicUrl(storagePath);

      final newImageId = _generateId(prefix: 'img');
      
      await supabase.from('immagine').insert({
        'idimmagine': newImageId,
        'url': imageUrl,
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
    required String pollutionLevel, // NUOVO PARAMETRO
    required double latitude,
    required double longitude,
    required String userId,
    String? imageId, // Ora opzionale
  }) async {
    try {
      final reportId = _generateId(prefix: 'rep');
      final fullDescription = description;

      await supabase.from('segnalazione').insert({
        'idsegnalazione': reportId,
        'idutente': userId,
        'idimmagine': imageId, 
        'latitudine': latitude,
        'longitudine': longitude,
        'livelloinquinamento': pollutionLevel, // Usa il valore passato
        'tipoinquinamento': fullDescription.length > 255 
            ? fullDescription.substring(0, 255) 
            : fullDescription,
        'ultimoaggiornamento': DateTime.now().toIso8601String(),
        'datacreazione': DateTime.now().toIso8601String(),
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
      final eventId = _generateId(prefix: 'evt'); // Generazione ID evento

      await supabase.from('evento').insert({
        'idevento': eventId,
        'titolo': title,
        'descrizione': description,
        'categoria': wasteType,
        'dataorainizio': date.toIso8601String(),
        'dataorafine': date.add(const Duration(hours: 3)).toIso8601String(),
        'localita': "Lat: $latitude, Lon: $longitude",
        'latitudine': latitude,
        'longitudine': longitude,
        'immagine': null,
      });

       //INVIO NOTIFICA LOCALE
      await NotificheService.nuovaNotificaEvento(
        nomeEvento: title,
        descrizione: description,
        immagineLocale: null, // Se hai un'immagine locale cambia questo
      );

    } on PostgrestException catch (e) {
      debugPrint('ERRORE SUPABASE [createEvent]: ${e.message}');
      throw Exception('Errore nel salvataggio evento: ${e.message}');
    } catch (e) {
      debugPrint('ERRORE GENERICO [createEvent]: $e');
      throw Exception('Errore sconosciuto: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> getReports() async {
    try {
      final response = await supabase
          .from('segnalazione')
          .select();

      return (response as List).map((item) => item as Map<String, dynamic>).toList();

    } on PostgrestException catch (e) {
      debugPrint('ERRORE SUPABASE [getReports]: ${e.message}');
      throw Exception('Errore nel caricamento delle segnalazioni: ${e.message}');
    } catch (e) {
      debugPrint('ERRORE GENERICO [getReports]: $e');
      throw Exception('Errore sconosciuto: $e');
    }
  }
}

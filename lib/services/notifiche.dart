import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificheService {
  static final FlutterLocalNotificationsPlugin _notifiche =
  FlutterLocalNotificationsPlugin();

  /// Inizializzazione
  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit);

    await _notifiche.initialize(initSettings);
  }

  /// Metodo generico per inviare una notifica
  static Future<void> _showNotification({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    AndroidNotificationDetails androidDetails;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      androidDetails = AndroidNotificationDetails(
        'notifiche_canale',
        'Notifiche App',
        channelDescription: 'Notifiche personalizzate della tua app',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: BigPictureStyleInformation(
          FilePathAndroidBitmap(imageUrl),
          contentTitle: title,
          summaryText: body,
        ),
      );
    } else {
      androidDetails = const AndroidNotificationDetails(
        'notifiche_canale',
        'Notifiche App',
        channelDescription: 'Notifiche personalizzate della tua app',
        importance: Importance.max,
        priority: Priority.high,
      );
    }

    NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notifiche.show(
      DateTime.now().millisecond, // ID univoco
      title,
      body,
      details,
    );
  }

  // 1) NOTIFICA NUOVO EVENTO
  static Future<void> nuovaNotificaEvento({
    required String nomeEvento,
    required String descrizione,
    required String immagineLocale,
  }) async {
    await _showNotification(
      title: "Nuovo evento disponibile!",
      body: "$nomeEvento — $descrizione",
      imageUrl: immagineLocale,
    );
  }

  // 2) NOTIFICA PREMIO RISCATTATO
  static Future<void> premioRiscattato({
    required String nomePremio,
    required String immagineLocale,
  }) async {
    await _showNotification(
      title: "Premio riscattato!",
      body: "Hai riscattato: $nomePremio",
      imageUrl: immagineLocale,
    );
  }

  // 3) NOTIFICA CAMBIO PASSWORD (CODICE INVIATO VIA E-MAIL)
  static Future<void> notificaCodicePassword({
    required String codice,
  }) async {
    await _showNotification(
      title: "Codice reset password",
      body: "Il tuo codice è: $codice",
    );
  }
}

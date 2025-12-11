import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificheService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Inizializzazione del plugin
  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // Azione quando l’utente clicca sulla notifica
      },
    );

    // Richiesta permesso su Android 13+
    if (Platform.isAndroid) {
      final androidImplementation =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        // Controlla se siamo su Android 13+
        if (await Permission.notification.isDenied) {
          await Permission.notification.request();
        }
      }
    }
  }

  /// 1) Notifica nuovo evento
  static Future<void> nuovaNotificaEvento({
    required String nomeEvento,
    String? descrizione,
    String? immagineLocale,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'event_channel',
      'Eventi',
      channelDescription: 'Notifiche per nuovi eventi',
      importance: Importance.max,
      priority: Priority.high,
      largeIcon: immagineLocale != null
          ? DrawableResourceAndroidBitmap(immagineLocale)
          : null,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      nomeEvento,
      descrizione ?? 'Nuovo evento disponibile!',
      details,
    );
  }

  /// 2) Notifica premio riscattato
  static Future<void> premioRiscattato({
    required String nomePremio,
    String? descrizione,
    String? immagineLocale,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'reward_channel',
      'Premi',
      channelDescription: 'Notifiche per premi riscattati',
      importance: Importance.max,
      priority: Priority.high,
      largeIcon: immagineLocale != null
          ? DrawableResourceAndroidBitmap(immagineLocale)
          : null,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      1,
      nomePremio,
      descrizione ?? 'Hai riscattato un premio!',
      details,
    );
  }

  /// 3) Notifica codice cambio password
  static Future<void> notificaCodicePassword({
    required String codice,
    String titolo = 'Cambio password',
    String descrizione = '',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'password_channel',
      'Password',
      channelDescription: 'Notifiche per cambio password',
      importance: Importance.max,
      priority: Priority.high,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      2,
      titolo,
      descrizione.isNotEmpty ? descrizione : 'Il tuo codice è: $codice',
      details,
    );
  }
}

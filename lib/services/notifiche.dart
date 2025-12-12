import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificheService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // Azione al tap sulla notifica (opzionale)
      },
    );
  }

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
          ? const DrawableResourceAndroidBitmap('spunta') // CORRETTO
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
          ? const DrawableResourceAndroidBitmap('spunta') // CORRETTO
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

  static Future<void> notificaCodicePassword({
    required String codice,
    String titolo = 'Cambio password',
    String descrizione = '',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'password_channel',
      'Password',
      channelDescription: 'Notifiche per cambio password',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      2,
      titolo,
      descrizione.isNotEmpty ? descrizione : 'Il tuo codice è: $codice',
      details,
    );
  }
}

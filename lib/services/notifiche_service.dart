import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
        await androidImplementation.requestPermission();
      }
    }
  }
}
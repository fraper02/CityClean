import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cityclean/main.dart';
import 'package:cityclean/screens/reset_password_screen.dart';

class NotificheService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // -----------------------------------------------------------
  // INIT
  // -----------------------------------------------------------
  static Future<void> init() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        _gestisciClickNotifica(response.payload);
      },
    );

    // Permessi Android 13+
    if (Platform.isAndroid) {
      final androidImpl =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidImpl?.requestPermission();
    }
  }

  // -----------------------------------------------------------
  // GESTIONE CLICK NOTIFICA
  // -----------------------------------------------------------
  static void _gestisciClickNotifica(String? payload) {
    if (payload == null) return;

    // 1️⃣ RECUPERO PASSWORD
    // payload = "pwd|email"
    if (payload.startsWith("pwd|")) {
      final email = payload.split("|")[1];

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: email),
        ),
      );
      return;
    }
  }

  // -----------------------------------------------------------
  // 1️⃣ NOTIFICA RECUPERO PASSWORD
  // -----------------------------------------------------------
  static Future<void> notificaCodicePassword({
    required String codice,
    required String email,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'password_channel',
      'Recupero password',
      channelDescription: 'Notifiche cambio password',
      importance: Importance.max,
      priority: Priority.high,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      1,
      "Codice di recupero",
      "Il tuo codice è: $codice",
      details,
      payload: "pwd|$email",
    );
  }

  // -----------------------------------------------------------
  // 2️⃣ NOTIFICA PREMIO RISCATTATO
  // -----------------------------------------------------------
  static Future<void> premioRiscattato({
    required String nomePremio,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'reward_channel',
      'Premi',
      channelDescription: 'Premi riscattati dall’utente',
      importance: Importance.max,
      priority: Priority.high,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      2,
      "Premio riscattato!",
      "Hai riscattato: $nomePremio",
      details,
      payload: "reward|$nomePremio",
    );
  }


  // -----------------------------------------------------------
  // 3️⃣ NOTIFICA NUOVO REPORT
  // -----------------------------------------------------------
  static Future<void> reportCreato({
    required String descrizione,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'report_channel',
      'Segnalazioni',
      channelDescription: 'Notifiche nuove segnalazioni',
      importance: Importance.max,
      priority: Priority.high,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      3,
      "Segnalazione inviata",
      descrizione,
      details,
      payload: "report|$descrizione",
    );
  }
}

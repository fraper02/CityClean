import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  // Chiavi costanti per evitare errori di battitura
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';

  // --- METODI GENERICI ---

  // Salva una stringa
  static Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  // Legge una stringa (ritorna null se non esiste)
  static Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  // Cancella una chiave specifica
  static Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  // Cancella TUTTO (utile al logout)
  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // --- METODI SPECIFICI PER L'APP (Convenience Methods) ---
  // Questi metodi rendono il codice nel resto dell'app più leggibile

  // Gestione Access Token
  static Future<void> saveAccessToken(String token) async {
    await write(key: _keyAccessToken, value: token);
  }

  static Future<String?> getAccessToken() async {
    return await read(key: _keyAccessToken);
  }

  // Gestione User ID
  static Future<void> saveUserId(String userId) async {
    await write(key: _keyUserId, value: userId);
  }

  static Future<String?> getUserId() async {
    return await read(key: _keyUserId);
  }

  // Metodo completo di salvataggio sessione (utile dopo il login)
  static Future<void> saveSession(String accessToken, String refreshToken, String userId) async {
    await Future.wait([
      write(key: _keyAccessToken, value: accessToken),
      write(key: _keyRefreshToken, value: refreshToken),
      write(key: _keyUserId, value: userId),
    ]);
  }

  // Metodo completo di pulizia (utile al logout)
  static Future<void> clearSession() async {
    await deleteAll();
  }




}
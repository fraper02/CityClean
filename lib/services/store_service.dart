import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/affiliated_store.dart';

class StoreService {
  final String baseUrl = "http://10.0.2.2:3000"; // CAMBIALO col tuo

  Future<List<AffiliatedStore>> getStores() async {
    final res = await http.get(Uri.parse("$baseUrl/api/stores"));

    if (res.statusCode != 200) {
      throw Exception("Errore caricamento negozi");
    }

    final List data = json.decode(res.body);
    return data.map((e) => AffiliatedStore.fromJson(e)).toList();
  }
}

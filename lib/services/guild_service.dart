import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/guild.dart';

class GuildService {
  final SupabaseClient _client = Supabase.instance.client;

  // Recupera la lista di tutte le gilde con i dettagli dei membri
  Future<List<Guild>> getGuilds() async {
    try {
      // MODIFICA: Seleziona anche idcreatore e membriid
      final response = await _client.from('party').select('idparty, nome, idcreatore, membriid, capienzamassima');
      final List<Guild> guilds = response.map<Guild>((data) => Guild.fromMap(data)).toList();
      return guilds;
    } catch (e) {
      print('Errore nel recuperare le gilde: $e');
      return [];
    }
  }

  // Permette a un utente di unirsi a una gilda
  Future<void> joinGuild(String guildId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato.");

    try {
      // Recupera lo stato attuale della gilda
      final guildData = await _client
          .from('party')
          .select('membriid, capienzamassima')
          .eq('idparty', guildId)
          .single();

      final List<dynamic> members = guildData['membriid'] ?? [];
      final int maxCapacity = guildData['capienzamassima'] ?? 0;

      // Controlli di sicurezza
      if (members.contains(user.id)) {
        throw Exception("Sei già un membro di questa gilda.");
      }
      if (members.length >= maxCapacity) {
        throw Exception("Questa gilda è al completo.");
      }

      // Aggiungi il nuovo membro e aggiorna il database
      final updatedMembers = List<String>.from(members.map((e) => e.toString()))..add(user.id);
      
      await _client
          .from('party')
          .update({'membriid': updatedMembers})
          .eq('idparty', guildId);

    } catch (e) {
      print("Errore durante l'unione alla gilda: $e");
      rethrow; // Rilancia l'eccezione per gestirla nella UI
    }
  }

  // Crea una nuova gilda
  Future<void> createGuild({required String name, required int maxCapacity}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato.');

    try {
      final guildId = 'GID_${DateTime.now().millisecondsSinceEpoch}';
      await _client.from('party').insert({
        'idparty': guildId,
        'idcreatore': user.id,
        'nome': name,
        'membriid': [user.id], // Il creatore è il primo membro
        'capienzamassima': maxCapacity,
      });
    } catch (e) {
      print('Errore durante la creazione della gilda: $e');
      rethrow;
    }
  }
}

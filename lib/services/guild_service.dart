import 'dart:convert'; // Aggiunto per gestire la conversione JSON
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/guild.dart';

class GuildService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Guild>> getGuilds() async {
    try {
      final response = await _client.from('party').select('idparty, nome, idcreatore, membriid, capienzamassima');
      final List<Guild> guilds = response.map<Guild>((data) => Guild.fromMap(data)).toList();
      return guilds;
    } catch (e) {
      print('Errore nel recuperare le gilde: $e');
      return [];
    }
  }

  Future<void> joinGuild(String guildId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato.");

    try {
      final guildData = await _client
          .from('party')
          .select('membriid, capienzamassima')
          .eq('idparty', guildId)
          .single();

      // CORREZIONE: `membriid` è una stringa JSON, non una lista.
      final String membersJson = guildData['membriid'] as String? ?? '[]';
      final List<dynamic> members = json.decode(membersJson);
      final int maxCapacity = guildData['capienzamassima'] ?? 0;

      if (members.contains(user.id)) {
        throw Exception("Sei già un membro di questa gilda.");
      }
      if (members.length >= maxCapacity) {
        throw Exception("Questa gilda è al completo.");
      }

      final updatedMembers = List<String>.from(members.map((e) => e.toString()))..add(user.id);
      
      // CORREZIONE: Salva la lista come stringa JSON.
      await _client
          .from('party')
          .update({'membriid': json.encode(updatedMembers)})
          .eq('idparty', guildId);

    } catch (e) {
      print("Errore durante l'unione alla gilda: $e");
      rethrow;
    }
  }

  Future<void> createGuild({required String name, required int maxCapacity}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato.');

    try {
      final guildId = 'GID_${DateTime.now().millisecondsSinceEpoch}';
      await _client.from('party').insert({
        'idparty': guildId,
        'idcreatore': user.id,
        'nome': name,
        // CORREZIONE: Salva la lista come stringa JSON.
        'membriid': json.encode([user.id]),
        'capienzamassima': maxCapacity,
      });
    } catch (e) {
      print('Errore durante la creazione della gilda: $e');
      rethrow;
    }
  }
}

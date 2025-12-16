import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/guild.dart';
import '../models/guild_details.dart';
import '../models/guild_member.dart';

class GuildService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String?> getUserGuild() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('partecipazione_party')
          .select('id_party')
          .eq('id_utente', user.id)
          .maybeSingle();

      if (response != null) {
        return response['id_party'] as String?;
      }
      return null;
    } catch (e) {
      print("Errore nel trovare la gilda dell'utente: $e");
      return null;
    }
  }

  Future<GuildDetails?> getGuildDetails(String guildId) async {
    try {
      final guildResponse = await _client.from('party').select().eq('idparty', guildId).single();

      final membersResponse = await _client
          .from('partecipazione_party')
          .select('utente(idutente, nome, cognome, codicereferral, fotoprofilo)')
          .eq('id_party', guildId);

      final List<GuildMember> members = membersResponse
          .map((data) => GuildMember.fromMap(data['utente'] ?? {}))
          .toList();

      return GuildDetails.fromMapWithMembers(guildMap: guildResponse, memberList: members);
    } catch (e) {
      print("Errore nel recuperare i dettagli della gilda: $e");
      return null;
    }
  }

  // NUOVO: Trasferisce la proprietà della gilda
  Future<void> transferOwnership(String guildId, String newCreatorId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato.");

    final guildData = await _client.from('party').select('idcreatore').eq('idparty', guildId).single();

    if (guildData['idcreatore'] != user.id) {
      throw Exception("Solo il creatore può trasferire la proprietà.");
    }
    if (user.id == newCreatorId) {
      throw Exception("Sei già il creatore di questa gilda.");
    }

    await _client
        .from('party')
        .update({'idcreatore': newCreatorId})
        .eq('idparty', guildId);
  }

  Future<void> kickMember(String guildId, String memberIdToKick) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato.");

    final guildData = await _client.from('party').select('idcreatore').eq('idparty', guildId).single();
    if (guildData['idcreatore'] != user.id) {
      throw Exception("Solo il creatore può espellere membri.");
    }
    if (user.id == memberIdToKick) {
      throw Exception("Non puoi espellere te stesso.");
    }

    await _client.from('partecipazione_party').delete().match({
      'id_party': guildId,
      'id_utente': memberIdToKick,
    });
  }

  Future<void> leaveGuild() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato.");

    final guildId = await getUserGuild();
    if (guildId == null) {
      throw Exception("Non sei membro di nessuna gilda.");
    }

    final guildData = await _client.from('party').select('idcreatore').eq('idparty', guildId).single();
    if (guildData['idcreatore'] == user.id) {
      throw Exception("Il creatore non può lasciare la gilda senza prima nominare un successore.");
    }

    await _client.from('partecipazione_party').delete().eq('id_utente', user.id);
  }

  Future<List<Guild>> getGuilds() async {
    try {
      final response = await _client.from('party').select('*, partecipazione_party(count)');

      final List<Guild> guilds = response.map<Guild>((data) {
        final participationData = data['partecipazione_party'] as List<dynamic>? ?? [];
        final memberCount = participationData.isNotEmpty ? participationData[0]['count'] as int : 0;
        
        final guildMap = Map<String, dynamic>.from(data);
        guildMap['members_count'] = memberCount;
        
        return Guild.fromMap(guildMap);
      }).toList();

      return guilds;
    } catch (e) {
      print('Errore nel recuperare le gilde: $e');
      return [];
    }
  }

  Future<void> joinGuild(String guildId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Utente non autenticato.");

    final guildData = await _client.from('party').select('capienzamassima').eq('idparty', guildId).single();
    
    final memberCount = await _client
        .from('partecipazione_party')
        .count()
        .eq('id_party', guildId);
    
    if (memberCount >= (guildData['capienzamassima'] ?? 0)) {
      throw Exception('Questa gilda è al completo.');
    }

    await _client.from('partecipazione_party').insert({
      'id_party': guildId,
      'id_utente': user.id,
    });
  }

  Future<void> createGuild({required String name, required int maxCapacity}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato.');

    final guildId = 'GID_${DateTime.now().millisecondsSinceEpoch}';

    await _client.from('party').insert({
      'idparty': guildId,
      'idcreatore': user.id,
      'nome': name,
      'capienzamassima': maxCapacity,
    });

    await _client.from('partecipazione_party').insert({
      'id_party': guildId,
      'id_utente': user.id,
    });
  }
}

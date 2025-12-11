import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/temporary_group.dart';
import '../models/temporary_group_member.dart';

class TemporaryGroupService {
  final SupabaseClient _client = Supabase.instance.client;
  String? get _userId => _client.auth.currentUser?.id;

  /// Crea un nuovo gruppo temporaneo e aggiunge il creatore come primo membro.
  Future<void> createGroup({required String name}) async {
    if (_userId == null) throw Exception("Utente non autenticato.");
    await _client.rpc('create_temporary_group_and_add_creator', params: {'group_name': name});
  }

  /// Si unisce a un gruppo tramite un codice di invito.
  Future<void> joinGroup(String inviteCode) async {
    if (_userId == null) throw Exception("Utente non autenticato.");
    await _client.rpc('join_temporary_group_by_code', params: {
      'p_invite_code': inviteCode,
      'p_user_id': _userId,
    });
  }

  /// Permette a un utente di lasciare il gruppo a cui appartiene.
  Future<void> leaveGroup() async {
    if (_userId == null) throw Exception("Utente non autenticato.");

    final canLeaveResult = await _client.rpc('can_user_leave_temp_group');
    if (canLeaveResult['can_leave'] == false) {
      throw Exception(canLeaveResult['message'] ?? "Non puoi lasciare il gruppo.");
    }

    await _client.from('temporary_group_members').delete().eq('user_id', _userId!);
  }

  /// Espelle un membro da un gruppo (solo per il creatore).
  Future<void> kickMember({required String groupId, required String memberId}) async {
    if (_userId == null) throw Exception("Utente non autenticato.");
    // La policy RLS garantisce che solo il creatore possa eseguire questa azione.
    await _client.from('temporary_group_members').delete().match({
      'group_id': groupId,
      'user_id': memberId,
    });
  }

  /// Trasferisce la proprietà di un gruppo a un nuovo membro.
  Future<void> transferOwnership({required String groupId, required String newOwnerId}) async {
    if (_userId == null) throw Exception("Utente non autenticato.");
    // La policy RLS garantisce che solo il creatore possa eseguire questa azione.
    await _client.from('temporary_groups').update({'creator_id': newOwnerId}).eq('id', groupId);
  }

  /// Crea un gruppo temporaneo con tutti i membri di un evento specifico.
  Future<void> createGroupFromEvent({required String eventId}) async {
    if (_userId == null) throw Exception("Utente non autenticato.");
    await _client.rpc('create_temporary_group_from_event', params: {'p_event_id': eventId});
  }

  /// Controlla se l'utente è in un gruppo e restituisce i dettagli.
  Future<TemporaryGroup?> getUserTemporaryGroup() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('temporary_group_members')
        .select('temporary_groups!inner(*, temporary_group_members(count)) ')
        .eq('user_id', user.id)
        .maybeSingle();

    if (response == null || response['temporary_groups'] == null) {
      return null;
    }

    return TemporaryGroup.fromMap(response['temporary_groups']);
  }

  /// Recupera i dettagli di un gruppo, inclusa la lista dei suoi membri.
  Future<List<TemporaryGroupMember>> getGroupMembers(String groupId) async {
    final response = await _client
        .from('temporary_group_members')
        .select('utente(idutente, nome, cognome, fotoprofilo)')
        .eq('group_id', groupId);

    return response
        .map((data) => TemporaryGroupMember.fromMap(data['utente'] ?? {}))
        .toList();
  }
}


class TemporaryGroup {
  final String id;
  final String creatorId;
  final String name;
  final String inviteCode;
  final DateTime createdAt;
  final int memberCount;

  TemporaryGroup({
    required this.id,
    required this.creatorId,
    required this.name,
    required this.inviteCode,
    required this.createdAt,
    required this.memberCount,
  });

  factory TemporaryGroup.fromMap(Map<String, dynamic> map) {
    // Il conteggio dei membri viene fornito da una relazione nel service.
    final members = map['temporary_group_members'] as List<dynamic>? ?? [];
    final count = members.isNotEmpty ? (members[0]['count'] as int? ?? 0) : 0;

    return TemporaryGroup(
      id: map['id'] as String,
      creatorId: map['creator_id'] as String,
      name: map['name'] as String,
      inviteCode: map['invite_code'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      memberCount: count,
    );
  }
}

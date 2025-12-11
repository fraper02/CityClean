import 'guild.dart';
import 'guild_member.dart';

class GuildDetails extends Guild {
  final List<GuildMember> members;

  GuildDetails({
    required super.id,
    required super.name,
    required super.description,
    required super.membersCount,
    required super.maxCapacity,
    required super.creatorId,
    required this.members,
  });

  factory GuildDetails.fromMapWithMembers({required Map<String, dynamic> guildMap, required List<GuildMember> memberList}) {
    final baseGuild = Guild.fromMap(guildMap);

    return GuildDetails(
      id: baseGuild.id,
      name: baseGuild.name,
      description: baseGuild.description,
      // Il conteggio dei membri ora viene dalla lista passata, non più dalla mappa
      membersCount: memberList.length,
      maxCapacity: baseGuild.maxCapacity,
      creatorId: baseGuild.creatorId,
      members: memberList,
    );
  }
}

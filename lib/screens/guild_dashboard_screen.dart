import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/guild_dashboard_controller.dart';
import '../models/guild_details.dart';
import '../models/guild_member.dart';
import 'group_screen.dart';

class GuildDashboardScreen extends StatelessWidget {
  final String guildId;

  const GuildDashboardScreen({super.key, required this.guildId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GuildDashboardController(guildId),
      child: Consumer<GuildDashboardController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            body: _buildBody(context, controller),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, GuildDashboardController controller) {
    if (controller.isLoading && controller.guildDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error != null) {
      return Center(child: Text(controller.error!, style: const TextStyle(color: Colors.red)));
    }
    if (controller.guildDetails == null) {
      return const Center(child: Text("Nessun dettaglio trovato per questa gilda."));
    }

    final guild = controller.guildDetails!;
    final isCreator = controller.currentUserId == guild.creatorId;

    return Column(
      children: [
        _buildHeader(context, controller, guild, isCreator),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => controller.fetchGuildDetails(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: guild.members.length,
              itemBuilder: (context, index) {
                final member = guild.members[index];
                return _buildMemberCard(context, member, controller);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, GuildDashboardController controller, GuildDetails guild, bool isCreator) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                    onPressed: () => controller.fetchGuildDetails(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildGuildInfoCard(context, controller, guild, isCreator),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuildInfoCard(BuildContext context, GuildDashboardController controller, GuildDetails guild, bool isCreator) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFE0F2F1),
            child: Icon(Icons.group_work_outlined, size: 30, color: Colors.green),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(guild.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${guild.membersCount} / ${guild.maxCapacity} membri', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          isCreator
            ? const Chip(label: Text('Creatore'), backgroundColor: Color(0xFFFFF3E0), visualDensity: VisualDensity.compact)
            : ElevatedButton.icon(
                onPressed: () => _confirmLeaveGuild(context, controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red[800],
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.exit_to_app, size: 20),
                label: const Text('Lascia'),
              ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, GuildMember member, GuildDashboardController controller) {
    final isCurrentUserCreator = controller.currentUserId == controller.guildDetails!.creatorId;
    final isThisMemberTheCreator = controller.guildDetails!.creatorId == member.id;
    final canPerformActions = isCurrentUserCreator && !isThisMemberTheCreator;
    final fullName = '${member.name} ${member.surname ?? ''}'.trim();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!)
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: member.profilePictureUrl != null && member.profilePictureUrl!.isNotEmpty ? NetworkImage(member.profilePictureUrl!) : null,
          child: member.profilePictureUrl == null || member.profilePictureUrl!.isEmpty ? Text(member.name.isNotEmpty ? member.name[0] : '?') : null,
        ),
        title: Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Codice: ${member.referralCode ?? 'N/D'}'),
        trailing: canPerformActions
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.workspace_premium_outlined, color: Colors.amber), onPressed: () => _confirmTransferOwnership(context, controller, member)),
                IconButton(icon: const Icon(Icons.person_remove, color: Colors.red), onPressed: () => _confirmKickMember(context, controller, member)),
              ])
            : (isThisMemberTheCreator)
                ? const Chip(label: Text('Creatore'), backgroundColor: Color(0xFFFFF3E0), visualDensity: VisualDensity.compact)
                : null,
      ),
    );
  }
}

void _confirmKickMember(BuildContext context, GuildDashboardController controller, GuildMember member) {
  showDialog(context: context, builder: (ctx) => AlertDialog(
    title: const Text('Conferma Espulsione'),
    content: Text('Sei sicuro di voler espellere ${member.name}?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
      ElevatedButton(onPressed: () { Navigator.pop(ctx); controller.kickMember(member.id); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('Espelli')),
    ],
  ));
}

void _confirmTransferOwnership(BuildContext context, GuildDashboardController controller, GuildMember member) {
  showDialog(context: context, builder: (ctx) => AlertDialog(
    title: const Text('Trasferisci Proprietà'),
    content: Text('Sei sicuro di voler nominare ${member.name} come nuovo creatore?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
      ElevatedButton(onPressed: () { Navigator.pop(ctx); controller.transferOwnership(member.id); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black), child: const Text('Conferma')),
    ],
  ));
}

void _confirmLeaveGuild(BuildContext context, GuildDashboardController controller) {
  showDialog(context: context, builder: (ctx) => AlertDialog(
    title: const Text('Lasciare la Gilda?'),
    content: const Text('Sei sicuro di voler lasciare questa gilda?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
      ElevatedButton(onPressed: () async {
        Navigator.pop(ctx);
        await controller.leaveGuild();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const GroupScreen()), (route) => false);
        }
      }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('Lascia')),
    ],
  ));
}

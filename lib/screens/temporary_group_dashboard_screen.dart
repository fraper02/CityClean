import 'package:cityclean/controllers/temporary_group_controller.dart';
import 'package:cityclean/models/temporary_group.dart';
import 'package:cityclean/models/temporary_group_member.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TemporaryGroupDashboardScreen extends StatelessWidget {
  const TemporaryGroupDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TemporaryGroupController>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _buildDashboardBody(context, controller),
    );
  }

  Widget _buildDashboardBody(BuildContext context, TemporaryGroupController controller) {
    if (controller.isLoading && controller.group == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error != null) {
      return Center(child: Text(controller.error!, style: const TextStyle(color: Colors.red)));
    }
    if (controller.group == null) {
      return const Center(child: Text("Non fai parte di nessun gruppo."));
    }

    final group = controller.group!;
    final isCreator = controller.currentUserId == group.creatorId;

    return Column(
      children: [
        _buildHeader(context, controller, group, isCreator),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => controller.loadGroupDetails(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.members.length,
              itemBuilder: (context, index) {
                final member = controller.members[index];
                return _buildMemberCard(context, member, controller);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, TemporaryGroupController controller, TemporaryGroup group, bool isCreator) {
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
                  Row(
                    children: [
                      // MODIFICA FINALE: Mostra il pulsante solo se non sei il capo, o se sei il capo e sei l'unico membro.
                      if (!isCreator || (isCreator && group.memberCount == 1))
                        IconButton(
                          icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                          onPressed: () => _confirmLeaveGroup(context, controller),
                          tooltip: 'Lascia gruppo',
                        ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                        onPressed: () => controller.loadGroupDetails(),
                        tooltip: 'Aggiorna',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildGroupInfoCard(context, group),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupInfoCard(BuildContext context, TemporaryGroup group) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFE0F2F1),
                child: Icon(Icons.timer_outlined, size: 30, color: Colors.blue),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${group.memberCount} membri - Scade a mezzanotte', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, indent: 10, endIndent: 10),
          const Text("Invita con questo codice", style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SelectableText(
                group.inviteCode,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 3, color: Colors.black87),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.green),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: group.inviteCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Codice invito copiato!')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, TemporaryGroupMember member, TemporaryGroupController controller) {
    final isCurrentUserCreator = controller.currentUserId == controller.group!.creatorId;
    final isThisMemberTheCreator = controller.group!.creatorId == member.id;
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
          child: (member.profilePictureUrl == null || member.profilePictureUrl!.isEmpty) ? Text(member.name.isNotEmpty ? member.name[0] : '?') : null,
        ),
        title: Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: isThisMemberTheCreator ? const Text('Capo', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)) : null,
        trailing: canPerformActions
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.workspace_premium_outlined, color: Colors.amber), tooltip: 'Nomina Capo', onPressed: () => _confirmTransferOwnership(context, controller, member)),
                IconButton(icon: const Icon(Icons.person_remove, color: Colors.red), tooltip: 'Espelli', onPressed: () => _confirmKick(context, controller, member)),
              ])
            : null,
      ),
    );
  }
}

void _confirmKick(BuildContext context, TemporaryGroupController controller, TemporaryGroupMember member) {
  showDialog(context: context, builder: (ctx) => AlertDialog(
    title: const Text('Conferma Espulsione'),
    content: Text('Sei sicuro di voler espellere ${member.name}?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
      ElevatedButton(
        onPressed: () { Navigator.pop(ctx); controller.kickMember(member.id); }, 
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), 
        child: const Text('Espelli'),
      ),
    ],
  ));
}

void _confirmTransferOwnership(BuildContext context, TemporaryGroupController controller, TemporaryGroupMember member) {
  showDialog(context: context, builder: (ctx) => AlertDialog(
    title: const Text('Trasferisci Proprietà'),
    content: Text('Sei sicuro di voler nominare ${member.name} come nuovo Capo?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
      ElevatedButton(
        onPressed: () { Navigator.pop(ctx); controller.transferOwnership(member.id); }, 
        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black), 
        child: const Text('Conferma'),
      ),
    ],
  ));
}

void _confirmLeaveGroup(BuildContext context, TemporaryGroupController controller) {
  showDialog(context: context, builder: (ctx) => AlertDialog(
    title: const Text('Lasciare il Gruppo?'),
    content: const Text('Sei sicuro di voler lasciare questo gruppo?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
      ElevatedButton(
        onPressed: () async {
          Navigator.pop(ctx);
          await controller.leaveGroup();
        }, 
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
        child: const Text('Lascia'),
      ),
    ],
  ));
}

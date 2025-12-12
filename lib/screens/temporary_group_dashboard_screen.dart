import 'package:cityclean/controllers/temporary_group_controller.dart';
import 'package:cityclean/models/temporary_group_member.dart';
import 'package:cityclean/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TemporaryGroupDashboardScreen extends StatelessWidget {
  const TemporaryGroupDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TemporaryGroupController>(context);

    // Gestione stati
    if (controller.isLoading && controller.group == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (controller.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Errore")),
        body: Center(child: Text(controller.error!, style: const TextStyle(color: Colors.red))),
      );
    }
    if (controller.group == null) {
      return const Scaffold(body: Center(child: Text("Nessun gruppo attivo.")));
    }

    final group = controller.group!;
    final isCreator = controller.currentUserId == group.creatorId;

    // Logica tasto Lascia
    final bool showLeaveButton = !isCreator || (isCreator && controller.members.length == 1);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // 1. HEADER ELASTICO
          SliverAppBar(
            expandedHeight: 240.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.green[700],
            elevation: 0,
            leading: IconButton(
              key: const Key('btn_dashboard_back'), // KEY AGGIUNTA
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                key: const Key('btn_dashboard_home'), // KEY AGGIUNTA
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false
                  );
                },
                icon: const Icon(Icons.home_rounded, color: Colors.white),
                tooltip: "Torna alla Home",
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              collapseMode: CollapseMode.parallax,
              title: Text(
                group.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.green[800]!, Colors.green[600]!],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.diversity_3_rounded, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      // Badge 24 ore
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer, color: Colors.white70, size: 12),
                            SizedBox(width: 4),
                            Text("Gruppo attivo per 24h", style: TextStyle(color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. CONTENUTO
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // BOX CODICE INVITO
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    elevation: 2,
                    child: InkWell(
                      key: const Key('btn_copy_code'), // KEY AGGIUNTA
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: group.inviteCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Codice copiato negli appunti!"), duration: Duration(seconds: 1)),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10)),
                              child: Icon(Icons.qr_code, color: Colors.green[700]),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("CODICE INVITO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text(
                                    group.inviteCode,
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.copy_rounded, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BOX BONUS CONFERIMENTI
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange[50]!, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_graph_rounded, color: Colors.orange, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bonus Conferimenti Attivo",
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Fino a quando resti nel gruppo, ottieni punti extra su ogni conferimento!",
                                style: TextStyle(color: Colors.grey[700], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // INTESTAZIONE MEMBRI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Membri (${controller.members.length})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (isCreator)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            children: [
                              Icon(Icons.shield, size: 12, color: Colors.orange),
                              SizedBox(width: 4),
                              Text("Sei il Capo", style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // LISTA MEMBRI
                  ...controller.members.map((member) => _buildMemberTile(context, member, controller, isCreator, group.creatorId)),

                  const SizedBox(height: 40),

                  // TASTO USCITA
                  if (showLeaveButton)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        key: const Key('btn_leave_group'), // KEY AGGIUNTA
                        onPressed: () => _confirmLeaveGroup(context, controller),
                        icon: const Icon(Icons.exit_to_app_rounded),
                        label: const Text("Lascia il Gruppo"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Text(
                        "Cedi la leadership per lasciare il gruppo",
                        style: TextStyle(color: Colors.grey[400], fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(BuildContext context, TemporaryGroupMember member, TemporaryGroupController controller, bool amICreator, String creatorId) {
    final bool isMemberCreator = member.id == creatorId;
    final bool isMe = member.id == controller.currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isMemberCreator ? Colors.orange.withOpacity(0.5) : Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: isMemberCreator ? Colors.orange[100] : Colors.green[50],
          child: isMemberCreator
              ? const Icon(Icons.shield_rounded, color: Colors.orange)
              : Text(
            member.name.isNotEmpty ? member.name.substring(0, 1).toUpperCase() : "?",
            style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (member.surname != null) Text(" ${member.surname!}"),
            if (isMemberCreator) ...[
              const SizedBox(width: 6),
              const Icon(Icons.stars_rounded, color: Colors.orange, size: 16),
            ],
            if (isMe) ...[
              const SizedBox(width: 6),
              Text("(Tu)", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ]
          ],
        ),
        subtitle: Text(
          isMemberCreator ? "Capo Gruppo" : "Partecipante",
          style: TextStyle(color: isMemberCreator ? Colors.orange : Colors.grey[600], fontSize: 12),
        ),
        trailing: (amICreator && !isMemberCreator)
            ? PopupMenuButton<String>(
          key: Key('btn_menu_member_${member.id}'), // KEY AGGIUNTA (Dinamica)
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (value) {
            if (value == 'promote') _confirmTransferOwnership(context, controller, member);
            if (value == 'kick') _confirmKickMember(context, controller, member);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              key: Key('menu_item_promote'), // KEY AGGIUNTA
              value: 'promote',
              child: Row(children: [Icon(Icons.shield_rounded, size: 20, color: Colors.orange), SizedBox(width: 10), Text("Cedi Comando")]),
            ),
            const PopupMenuItem(
              key: Key('menu_item_kick'), // KEY AGGIUNTA
              value: 'kick',
              child: Row(children: [Icon(Icons.person_remove_rounded, size: 20, color: Colors.red), SizedBox(width: 10), Text("Espelli")]),
            ),
          ],
        )
            : null,
      ),
    );
  }

  // --- DIALOGS ---

  void _confirmKickMember(BuildContext context, TemporaryGroupController controller, TemporaryGroupMember member) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Espelli Partecipante'),
      content: Text('Vuoi rimuovere ${member.name} dal gruppo?'),
      actions: [
        TextButton(
            key: const Key('btn_kick_cancel'), // KEY AGGIUNTA
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla')
        ),
        ElevatedButton(
          key: const Key('btn_kick_confirm'), // KEY AGGIUNTA
          onPressed: () { Navigator.pop(ctx); controller.kickMember(member.id); },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Espelli', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _confirmTransferOwnership(BuildContext context, TemporaryGroupController controller, TemporaryGroupMember member) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Column(
        children: [
          Icon(Icons.shield_rounded, size: 40, color: Colors.orange),
          SizedBox(height: 10),
          Text('Passaggio di Consegne'),
        ],
      ),
      content: Text('Vuoi nominare ${member.name} come nuovo Capo Gruppo?\nPerderai i diritti di amministrazione.', textAlign: TextAlign.center),
      actions: [
        TextButton(
            key: const Key('btn_promote_cancel'), // KEY AGGIUNTA
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla')
        ),
        ElevatedButton(
          key: const Key('btn_promote_confirm'), // KEY AGGIUNTA
          onPressed: () { Navigator.pop(ctx); controller.transferOwnership(member.id); },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('Conferma', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _confirmLeaveGroup(BuildContext context, TemporaryGroupController controller) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Lasciare il Gruppo?'),
      content: const Text('Sei sicuro di voler uscire? Se sei l\'ultimo membro, il gruppo verrà eliminato.'),
      actions: [
        TextButton(
            key: const Key('btn_leave_cancel'), // KEY AGGIUNTA
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla')
        ),
        ElevatedButton(
          key: const Key('btn_leave_confirm'), // KEY AGGIUNTA
          onPressed: () async {
            Navigator.pop(ctx);
            await controller.leaveGroup();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Lascia', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}
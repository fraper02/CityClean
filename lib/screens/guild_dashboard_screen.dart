import 'package:cityclean/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/guild_dashboard_controller.dart';
import '../models/guild_details.dart';
import '../models/guild_member.dart';

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
    // Gestione stati caricamento/errore
    if (controller.isLoading && controller.guildDetails == null) {
      return Center(child: CircularProgressIndicator(color: Colors.green[700]));
    }
    if (controller.error != null) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(controller.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
      ));
    }
    if (controller.guildDetails == null) {
      return const Center(child: Text("Nessun dettaglio trovato per questa gilda."));
    }

    final guild = controller.guildDetails!;

    // LOGICA CAPO GILDA
    final bool amICreator = guild.creatorId == controller.currentUserId;

    // LOGICA VISIBILITÀ TASTO USCITA:
    // Mostra il tasto SOLO SE: non sono il capo OPPURE sono il capo ma sono solo.
    final bool showLeaveButton = !amICreator || (amICreator && guild.members.length == 1);

    return CustomScrollView(
      slivers: [
        // 1. HEADER (SliverAppBar)
        SliverAppBar(
          expandedHeight: 260.0,
          floating: false,
          pinned: true,
          backgroundColor: Colors.green[700],
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: const EdgeInsets.only(bottom: 16),
            collapseMode: CollapseMode.parallax,
            title: Text(
              guild.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green[800]!, Colors.green[600]!],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Avatar Gilda Grande
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      guild.name.isNotEmpty ? guild.name.substring(0, 1).toUpperCase() : "?",
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green[800]),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${guild.members.length} / ${guild.maxCapacity} Membri",
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 2. CONTENUTO SCORREVOLE
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DESCRIZIONE
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                          const SizedBox(width: 8),
                          const Text("Info Gilda", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Divider(height: 20),
                      Text(
                        guild.description,
                        style: TextStyle(color: Colors.grey[700], height: 1.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Membri", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (amICreator)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.security, size: 14, color: Colors.orange), // Piccola icona stemma
                            SizedBox(width: 4),
                            Text("Sei il Capo", style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // LISTA MEMBRI
                ...guild.members.map((member) => _buildMemberTile(context, member, controller, guild.creatorId, amICreator)),

                const SizedBox(height: 40),

                // TASTO ABBANDONA (CONDIZIONALE)
                if (showLeaveButton)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmLeaveGuild(context, controller),
                      icon: const Icon(Icons.exit_to_app_rounded),
                      label: const Text("Lascia la Gilda"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                else
                // Feedback visivo opzionale se vuoi spiegare perché non c'è il tasto (puoi rimuoverlo se vuoi solo spazio vuoto)
                  Center(
                    child: Text(
                      "Cedi il ruolo di Capo per lasciare la gilda",
                      style: TextStyle(color: Colors.grey[400], fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberTile(BuildContext context, GuildMember member, GuildDashboardController controller, String creatorId, bool amICreator) {
    final bool isThisMemberCreator = member.id == creatorId;
    final bool isMe = member.id == controller.currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isThisMemberCreator ? Colors.orange.withOpacity(0.5) : Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isThisMemberCreator ? Colors.orange[100] : Colors.green[50],
          child: isThisMemberCreator
              ? const Icon(Icons.shield_rounded, color: Colors.orange) // ICONA STEMMA PER IL CAPO
              : Text(
            member.name.isNotEmpty ? member.name.substring(0, 1).toUpperCase() : "?",
            style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (isThisMemberCreator) ...[
              const SizedBox(width: 8),
              const Icon(Icons.stars_rounded, color: Colors.orange, size: 18),
            ],
            if (isMe) ...[
              const SizedBox(width: 8),
              Text("(Tu)", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ]
          ],
        ),
        subtitle: Text(
          isThisMemberCreator ? "Capo Gilda" : "Membro",
          style: TextStyle(color: isThisMemberCreator ? Colors.orange : Colors.grey[600], fontSize: 12),
        ),
        trailing: (amICreator && !isThisMemberCreator)
            ? PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (value) {
            if (value == 'promote') _confirmTransferOwnership(context, controller, member);
            if (value == 'kick') _confirmKickMember(context, controller, member);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'promote',
              child: Row(
                  children: [
                    Icon(Icons.shield_rounded, size: 20, color: Colors.orange), // Icona Stemma nel menu
                    SizedBox(width: 10),
                    Text("Promuovi a Capo")
                  ]
              ),
            ),
            const PopupMenuItem(
              value: 'kick',
              child: Row(
                  children: [
                    Icon(Icons.person_remove_rounded, size: 20, color: Colors.red),
                    SizedBox(width: 10),
                    Text("Espelli")
                  ]
              ),
            ),
          ],
        )
            : null,
      ),
    );
  }

  // --- DIALOGHI ---

  void _confirmTransferOwnership(BuildContext context, GuildDashboardController controller, GuildMember member) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Column(
        children: [
          Icon(Icons.shield_rounded, size: 50, color: Colors.orange), // GRANDE ICONA STEMMA
          SizedBox(height: 10),
          Text('Cambio Capo Gilda'),
        ],
      ),
      content: Text(
        'Stai per passare lo stemma del comando a ${member.name}.\n\nTu diventerai un membro normale e potrai lasciare la gilda se vorrai.',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            controller.transferOwnership(member.id);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('Conferma Cambio', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _confirmKickMember(BuildContext context, GuildDashboardController controller, GuildMember member) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Espelli Membro'),
      content: Text('Vuoi rimuovere ${member.name} dalla gilda?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            controller.kickMember(member.id);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Espelli', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _confirmLeaveGuild(BuildContext context, GuildDashboardController controller) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Lasciare la Gilda?'),
      content: const Text('Sei sicuro di voler uscire?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await controller.leaveGuild();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Lascia', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}
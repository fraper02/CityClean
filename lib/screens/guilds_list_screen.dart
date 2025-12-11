import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/guild_controller.dart';
import '../models/guild.dart';
import 'create_guild_screen.dart';

class GuildsListScreen extends StatefulWidget {
  const GuildsListScreen({super.key});

  @override
  State<GuildsListScreen> createState() => _GuildsListScreenState();
}

class _GuildsListScreenState extends State<GuildsListScreen> {
  late final GuildController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = GuildController();
    _controller.addListener(_handleControllerChanges);
    _searchController.addListener(() {
      _controller.filterGuilds(_searchController.text);
    });
  }

  void _handleControllerChanges() {
    if (_controller.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.error!), backgroundColor: Colors.red),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanges);
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text("Gilde"),
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _controller.isLoading ? null : () => _controller.fetchGuilds(),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cerca gilda per nome...",
                      prefixIcon: const Icon(Icons.search, color: Colors.green),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer<GuildController>(
                    builder: (context, controller, child) {
                      return _buildGuildList(controller);
                    },
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateGuildScreen(controller: _controller),
                      ),
                    );
                  },
                  backgroundColor: primaryGreen,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Crea Gilda", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuildList(GuildController controller) {
    if (controller.isLoading && controller.filteredGuilds.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error != null && controller.filteredGuilds.isEmpty) {
      return Center(child: Text(controller.error!, style: const TextStyle(color: Colors.red)));
    }
    if (controller.filteredGuilds.isEmpty) {
      return const Center(child: Text("Nessuna gilda trovata."));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
      itemCount: controller.filteredGuilds.length,
      itemBuilder: (context, index) {
        final guild = controller.filteredGuilds[index];
        return _buildGuildCard(guild, controller);
      },
    );
  }

  Widget _buildGuildCard(Guild guild, GuildController controller) {
    final String? currentUserId = controller.currentUserId;
    final bool userIsInAGuild = controller.userGuildId != null;
    
    bool isCreator = currentUserId == guild.creatorId;
    // CORREZIONE: La logica ora controlla se l'utente è membro di QUESTA gilda specifica.
    bool isMemberOfThisGuild = controller.userGuildId == guild.id;
    bool isFull = guild.membersCount >= guild.maxCapacity;

    // Logica per determinare lo stato del pulsante
    String buttonText;
    Color buttonColor;
    VoidCallback? onPressed;

    if (isCreator) {
      buttonText = "Creatore";
      buttonColor = Colors.grey;
      onPressed = null;
    } else if (isMemberOfThisGuild) {
      buttonText = "Membro";
      buttonColor = Colors.blueGrey;
      onPressed = null;
    } else if (isFull) {
      buttonText = "Completa";
      buttonColor = Colors.orange;
      onPressed = null;
    } else if (userIsInAGuild) {
      // L'utente è in un'altra gilda, quindi non può unirsi
      buttonText = "Unisciti";
      buttonColor = Colors.grey;
      onPressed = null;
    } else {
      // L'utente è libero di unirsi
      buttonText = "Unisciti";
      buttonColor = Colors.green[700]!;
      onPressed = () => controller.joinGuild(guild.id);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(backgroundColor: Colors.green[100], child: Text(guild.name.isNotEmpty ? guild.name[0].toUpperCase() : '?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]!))),
        title: Text(guild.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(guild.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.group, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text("${guild.membersCount} / ${guild.maxCapacity} membri", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: controller.isJoining ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: controller.isJoining && onPressed != null // Mostra il loader solo se questo è il pulsante attivo
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(buttonText),
        ),
      ),
    );
  }
}

import 'package:cityclean/screens/guild_dashboard_screen.dart';
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
    // CORRETTO: Metodo fetchGuilds
    _controller.fetchGuilds();
    _searchController.addListener(() {
      _controller.filterGuilds(_searchController.text);
    });
  }

  void _handleControllerChanges() {
    if (mounted) {
      if (_controller.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_controller.error!), backgroundColor: Colors.red),
        );
        // RIMOSSO: clearError non esiste, il controller gestisce l'errore internamente al prossimo fetch
      }
      if (_controller.justJoinedGuildId != null) {
        final guildId = _controller.justJoinedGuildId!;
        // CORRETTO: Nome metodo aggiornato
        _controller.clearJustJoinedState();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GuildDashboardScreen(guildId: guildId)),
        );
      }
      setState(() {});
    }
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
    const double headerHeight = 220.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            // CORRETTO: Passato il controller richiesto dal costruttore
            MaterialPageRoute(builder: (_) => CreateGuildScreen(controller: _controller)),
          ).then((_) => _controller.fetchGuilds()); // CORRETTO: fetchGuilds
        },
        backgroundColor: Colors.green[700],
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text("Crea Gilda", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          // 1. LIVELLO SFONDO: La Lista
          Positioned.fill(
            child: RefreshIndicator(
              // CORRETTO: Riferimento a fetchGuilds
              onRefresh: _controller.fetchGuilds,
              color: Colors.green[700],
              child: _controller.isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.green[700]))
                  : ListView(
                padding: const EdgeInsets.only(
                  top: headerHeight + 20,
                  left: 20,
                  right: 20,
                  bottom: 80, // Spazio per il FAB
                ),
                children: [
                  // BARRA DI RICERCA
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Cerca una gilda...",
                        prefixIcon: Icon(Icons.search, color: Colors.green[700]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // LISTA GILDE
                  // CORRETTO: Uso di filteredGuilds invece di guilds
                  if (_controller.filteredGuilds.isEmpty)
                    _buildEmptyState()
                  else
                    ..._controller.filteredGuilds.map((guild) => _buildGuildCard(guild)),
                ],
              ),
            ),
          ),

          // 2. LIVELLO HEADER VERDE
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green[800]!, Colors.green[600]!],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.green[900]!.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                ],
              ),
            ),
          ),

          // 3. LIVELLO CONTENUTO HEADER
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tasto Indietro
                    Row(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                              ),
                              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Titolo Pagina
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.groups_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          "Gilde Ecologiche",
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Text(
                        "Unisciti agli altri per pulire la città!",
                        style: TextStyle(fontSize: 15, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text("Nessuna gilda trovata", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildGuildCard(Guild guild) {
    final bool isMember = _controller.userGuildId == guild.id;
    final bool isFull = guild.membersCount >= guild.maxCapacity;

    String buttonText = "Unisciti";
    Color buttonColor = Colors.green[700]!;
    VoidCallback? onPressed = () => _controller.joinGuild(guild.id);

    if (isMember) {
      buttonText = "Membro";
      buttonColor = Colors.grey;
      onPressed = null;
    } else if (isFull) {
      buttonText = "Piena";
      buttonColor = Colors.red[300]!;
      onPressed = null;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: Text(
            guild.name.isNotEmpty ? guild.name.substring(0, 1).toUpperCase() : "?",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700], fontSize: 20),
          ),
        ),
        title: Text(guild.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(guild.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text("${guild.membersCount} / ${guild.maxCapacity} membri", style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _controller.isJoining ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                minimumSize: const Size(80, 36),
              ),
              child: _controller.isJoining && onPressed != null
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(buttonText, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
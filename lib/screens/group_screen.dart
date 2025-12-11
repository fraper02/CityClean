import 'package:flutter/material.dart';
import '../services/guild_service.dart';
import 'guild_dashboard_screen.dart';
import 'guilds_list_screen.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final GuildService _guildService = GuildService();

  @override
  void initState() {
    super.initState();
    _checkUserGuildStatus();
  }

  Future<void> _checkUserGuildStatus() async {
    // Attendi un frame per evitare problemi di build
    await Future.delayed(Duration.zero);

    final guildId = await _guildService.getUserGuild();

    if (mounted) {
      if (guildId != null) {
        // L'utente è in una gilda, vai alla dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GuildDashboardScreen(guildId: guildId)),
        );
      } else {
        // L'utente non è in una gilda, vai alla lista
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GuildsListScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostra un indicatore di caricamento mentre controlliamo lo stato
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

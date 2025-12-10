import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/guild.dart';
import '../services/guild_service.dart';

class GuildController with ChangeNotifier {
  final GuildService _guildService = GuildService();
  final String? currentUserId = Supabase.instance.client.auth.currentUser?.id;

  List<Guild> _allGuilds = [];
  List<Guild> _filteredGuilds = [];
  bool _isLoading = false;
  String? _error;
  bool _isJoining = false; // NUOVO: per gestire lo stato di unione

  List<Guild> get filteredGuilds => _filteredGuilds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isJoining => _isJoining; // NUOVO

  GuildController() {
    fetchGuilds();
  }

  Future<void> fetchGuilds() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allGuilds = await _guildService.getGuilds();
      _filteredGuilds = _allGuilds;
    } catch (e) {
      _error = "Errore nel caricamento delle gilde.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterGuilds(String keyword) {
    if (keyword.isEmpty) {
      _filteredGuilds = _allGuilds;
    } else {
      _filteredGuilds = _allGuilds
          .where((guild) =>
              guild.name.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // NUOVO: Metodo per unirsi a una gilda
  Future<void> joinGuild(String guildId) async {
    _isJoining = true;
    _error = null;
    notifyListeners();

    try {
      await _guildService.joinGuild(guildId);
      // Ricarica i dati per aggiornare lo stato (es. numero membri)
      await fetchGuilds();
    } catch (e) {
      _error = e.toString(); // Mostra l'errore specifico
    } finally {
      _isJoining = false;
      notifyListeners();
    }
  }

  Future<void> createGuild({required String name, required int maxCapacity}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _guildService.createGuild(name: name, maxCapacity: maxCapacity);
      await fetchGuilds();
    } catch (e) {
      _error = "Errore durante la creazione della gilda.";
      await fetchGuilds();
    } 
  }
}

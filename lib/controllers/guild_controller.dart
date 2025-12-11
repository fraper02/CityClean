import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/guild.dart';
import '../services/guild_service.dart';

class GuildController with ChangeNotifier {
  final GuildService _guildService = GuildService();
  final String? currentUserId = Supabase.instance.client.auth.currentUser?.id;

  List<Guild> _allGuilds = [];
  List<Guild> _filteredGuilds = [];
  String? _userGuildId;
  bool _isLoading = false;
  String? _error;
  bool _isJoining = false;

  // NUOVO: ID della gilda a cui ci si è appena uniti per gestire la navigazione.
  String? _justJoinedGuildId;

  List<Guild> get filteredGuilds => _filteredGuilds;
  String? get userGuildId => _userGuildId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isJoining => _isJoining;
  String? get justJoinedGuildId => _justJoinedGuildId;

  GuildController() {
    fetchGuilds();
  }

  // NUOVO: Metodo per resettare lo stato dopo la navigazione.
  void clearJustJoinedState() {
    _justJoinedGuildId = null;
  }

  Future<void> fetchGuilds() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allGuilds = await _guildService.getGuilds();
      _userGuildId = await _guildService.getUserGuild();
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

  Future<void> joinGuild(String guildId) async {
    _isJoining = true;
    _error = null;
    notifyListeners();

    try {
      await _guildService.joinGuild(guildId);
      // MODIFICA: Invece di ricaricare, imposta l'ID per la navigazione.
      _justJoinedGuildId = guildId;
    } catch (e) {
      _error = e.toString();
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

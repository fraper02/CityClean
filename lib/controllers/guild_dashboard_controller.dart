import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/guild_details.dart';
import '../services/guild_service.dart';

class GuildDashboardController with ChangeNotifier {
  final GuildService _guildService = GuildService();
  final String _guildId;
  final String? currentUserId = Supabase.instance.client.auth.currentUser?.id;

  GuildDetails? _guildDetails;
  bool _isLoading = false;
  String? _error;
  bool _isKicking = false;
  bool _isTransferring = false; // NUOVO: per il trasferimento di proprietà

  GuildDetails? get guildDetails => _guildDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isKicking => _isKicking;
  bool get isTransferring => _isTransferring; // NUOVO

  GuildDashboardController(this._guildId) {
    fetchGuildDetails();
  }

  Future<void> fetchGuildDetails() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _guildDetails = await _guildService.getGuildDetails(_guildId);
      if (_guildDetails == null) {
        _error = "Impossibile caricare i dettagli della gilda.";
      }
    } catch (e) {
      _error = "Si è verificato un errore: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // NUOVO: Metodo per trasferire la proprietà
  Future<void> transferOwnership(String newCreatorId) async {
    _isTransferring = true;
    _error = null;
    notifyListeners();

    try {
      await _guildService.transferOwnership(_guildId, newCreatorId);
      await fetchGuildDetails(); // Ricarica per vedere il nuovo creatore
    } catch (e) {
      _error = e.toString();
    } finally {
      _isTransferring = false;
      notifyListeners();
    }
  }

  Future<void> kickMember(String memberId) async {
    _isKicking = true;
    _error = null;
    notifyListeners();

    try {
      await _guildService.kickMember(_guildId, memberId);
      await fetchGuildDetails(); 
    } catch (e) {
      _error = e.toString();
    } finally {
      _isKicking = false;
      notifyListeners();
    }
  }

  Future<void> leaveGuild() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _guildService.leaveGuild();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

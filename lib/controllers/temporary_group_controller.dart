import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/temporary_group.dart';
import '../models/temporary_group_member.dart';
import '../services/temporary_group_service.dart';

class TemporaryGroupController with ChangeNotifier {
  final TemporaryGroupService _service = TemporaryGroupService();
  String? get currentUserId => Supabase.instance.client.auth.currentUser?.id;

  TemporaryGroup? _group;
  List<TemporaryGroupMember> _members = [];
  bool _isLoading = false;
  String? _error;

  TemporaryGroup? get group => _group;
  List<TemporaryGroupMember> get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TemporaryGroupController() {
    loadGroupDetails();
  }

  void clearError() {
    _error = null;
  }

  Future<void> _execute(Future<void> Function() operation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await operation();
      await loadGroupDetails();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGroupDetails() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _group = await _service.getUserTemporaryGroup();
      if (_group != null) {
        _members = await _service.getGroupMembers(_group!.id);
      } else {
        _members = [];
      }
    } catch (e) {
      _error = "Errore nel caricamento del gruppo: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createGroup(String name) async {
    await _execute(() => _service.createGroup(name: name));
  }

  Future<void> joinGroup(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.joinGroup(code);
      await loadGroupDetails();
    } catch (e) {
      if (e.toString().contains('Codice di invito non valido')) {
        _error = "Il codice che hai inserito non è valido o è scaduto. Riprova!";
      } else {
        _error = "Si è verificato un errore inaspettato. Riprova più tardi.";
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> leaveGroup() async {
    await _execute(() => _service.leaveGroup());
  }

  Future<void> kickMember(String memberId) async {
    if (_group == null) return;
    await _execute(() => _service.kickMember(groupId: _group!.id, memberId: memberId));
  }

  Future<void> transferOwnership(String newOwnerId) async {
    if (_group == null) return;
    await _execute(() => _service.transferOwnership(groupId: _group!.id, newOwnerId: newOwnerId));
  }
}

import 'package:cityclean/models/badge.dart' as app_badge;
import 'package:cityclean/models/user_profile.dart';
import 'package:cityclean/services/user_service.dart';
import 'package:flutter/material.dart';

enum ProfileScreenState { initial, loading, success, error }

class ProfileController {
  final UserService _userService;

  final ValueNotifier<ProfileScreenState> state = ValueNotifier(ProfileScreenState.initial);
  final ValueNotifier<UserProfile?> userProfile = ValueNotifier(null);
  final ValueNotifier<List<app_badge.Badge>> unlockedBadges = ValueNotifier([]);
  final ValueNotifier<String> errorMessage = ValueNotifier('');

  ProfileController({UserService? userService}) : _userService = userService ?? UserService();

  Future<void> loadUserProfile() async {
    state.value = ProfileScreenState.loading;
    try {
      // Carica sia il profilo sia i badge sbloccati in parallelo
      final results = await Future.wait([
        _userService.getCurrentUser(),
        _userService.getUnlockedBadges(),
      ]);
      userProfile.value = results[0] as UserProfile;
      unlockedBadges.value = results[1] as List<app_badge.Badge>;
      state.value = ProfileScreenState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = ProfileScreenState.error;
    }
  }

  Future<void> updateUserTitle(BuildContext context, String newBadgeId, String newBadgeName) async {
    try {
      await _userService.updateUserTitle(newBadgeId);
      // Ricarica il profilo per mostrare i dati aggiornati
      await loadUserProfile(); 
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Titolo aggiornato a "$newBadgeName"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Errore durante l'aggiornamento del titolo."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showTitleSelection(BuildContext context, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Scegli il tuo Titolo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: unlockedBadges.value.length,
                  itemBuilder: (context, index) {
                    final badge = unlockedBadges.value[index];
                    final isSelected = badge.id == userProfile.value?.idBadgeTitolo;
                    return ListTile(
                      leading: isSelected
                          ? Icon(Icons.radio_button_checked, color: primaryColor)
                          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                      title: Text(
                        badge.nome,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? primaryColor : Colors.black87,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        await updateUserTitle(context, badge.id, badge.nome);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void dispose() {
    state.dispose();
    userProfile.dispose();
    unlockedBadges.dispose();
    errorMessage.dispose();
  }
}

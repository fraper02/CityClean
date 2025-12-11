import 'package:cityclean/models/user_activity.dart';
import 'package:cityclean/services/user_activity_service.dart';
import 'package:flutter/foundation.dart';

enum UserActivityState { initial, loading, success, error }

class UserActivityController {
  final UserActivityService _service;

  final ValueNotifier<UserActivityState> state = ValueNotifier(UserActivityState.initial);
  final ValueNotifier<List<UserActivity>> activities = ValueNotifier([]);
  final ValueNotifier<String> errorMessage = ValueNotifier('');

  UserActivityController({UserActivityService? service}) : _service = service ?? UserActivityService();

  Future<void> loadActivities() async {
    state.value = UserActivityState.loading;
    try {
      activities.value = await _service.getCurrentUserActivity();
      state.value = UserActivityState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = UserActivityState.error;
    }
  }

  void dispose() {
    state.dispose();
    activities.dispose();
    errorMessage.dispose();
  }
}

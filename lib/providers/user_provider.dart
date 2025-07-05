import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

final userProvider = StateNotifierProvider<UserNotifier, User?>(
  (ref) => UserNotifier(),
);

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  void setUser(User user) {
    state = user;
  }

  void updateSessionId(String sessionId) {
    if (state != null) {
      state = state!.copyWith(currentSessionId: sessionId);
    }
  }

  void clearUser() {
    state = null;
  }
}

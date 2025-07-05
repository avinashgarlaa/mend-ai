import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/providers/mend_provider.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

final authViewModelProvider = Provider((ref) {
  return AuthViewModel(ref);
});

class AuthViewModel {
  final Ref ref;

  AuthViewModel(this.ref);

  /// Login via Partner ID
  Future<bool> login(String partnerId) async {
    final api = ref.read(mendServiceProvider);
    try {
      final response = await api.login(partnerId);
      final user = User.fromJson(response.data);
      ref.read(userProvider.notifier).setUser(user);
      return true;
    } catch (e) {
      print('Login failed: $e');
      return false;
    }
  }

  Future<bool> registerUser(Map<String, dynamic> userData) async {
    final api = ref.read(mendServiceProvider);
    try {
      final response = await api.registerUser(userData);
      final user = User.fromJson(response.data);
      ref.read(userProvider.notifier).setUser(user);
      return true;
    } catch (e) {
      print("Register failed: $e");
      return false;
    }
  }

  Future<bool> submitOnboardingOnly(Map<String, dynamic> data) async {
    final api = ref.read(mendServiceProvider);
    try {
      await api.submitOnboarding(data);
      return true;
    } catch (e) {
      print("Submit onboarding failed: $e");
      return false;
    }
  }

  /// Invite and link partner
  Future<bool> linkPartner(String yourId, String partnerId) async {
    final api = ref.read(mendServiceProvider);
    try {
      final res = await api.invitePartner({
        "yourId": yourId,
        "partnerId": partnerId,
      });
      print("Invite success: ${res.data}");
      return true;
    } catch (e) {
      print("Invite failed: $e");
      return false;
    }
  }
}

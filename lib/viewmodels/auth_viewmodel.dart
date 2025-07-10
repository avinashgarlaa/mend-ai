import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mend_ai/providers/mend_provider.dart';
import 'package:mend_ai/models/user_model.dart';
import 'package:mend_ai/providers/user_provider.dart';

final authViewModelProvider = Provider((ref) => AuthViewModel(ref));

class AuthViewModel {
  final Ref ref;

  AuthViewModel(this.ref);

  /// 🔐 Login using email
  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    final api = ref.read(mendServiceProvider);
    try {
      final response = await api.loginWithCredentials(email, password);
      final user = User.fromJson(response.data);
      ref.read(userProvider.notifier).setUser(user);
      await FlutterSecureStorage().write(key: 'email', value: email);
      await FlutterSecureStorage().write(key: 'password', value: password);

      return true;
    } catch (e) {
      print("Login failed: $e");
      return false;
    }
  }

  /// 🔁 Attempt auto-login if email/password saved
  Future<bool> tryAutoLogin() async {
    final email = await FlutterSecureStorage().read(key: 'email');
    final password = await FlutterSecureStorage().read(key: 'password');

    if (email == null || password == null) return false;

    try {
      final api = ref.read(mendServiceProvider);
      final response = await api.loginWithCredentials(email, password);
      final user = User.fromJson(response.data);

      ref.read(userProvider.notifier).setUser(user);
      return true;
    } catch (e) {
      print("Auto-login failed: $e");
      return false;
    }
  }

  /// 👤 Register new user with name, gender, and email
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

  Future<void> logout() async {
    await FlutterSecureStorage().delete(key: 'email');
    await FlutterSecureStorage().delete(key: 'password');
    ref.read(userProvider.notifier).clearUser();
  }

  /// 📝 Onboarding: Fill relationship details
  Future<bool> submitOnboarding(Map<String, dynamic> onboardingData) async {
    final api = ref.read(mendServiceProvider);
    try {
      await api.submitOnboarding(onboardingData);
      return true;
    } catch (e) {
      print("Submit onboarding failed: $e");
      return false;
    }
  }

  /// 🔗 Link to a partner via invite
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

  /// 🧠 Register and immediately submit onboarding
  Future<bool> registerAndOnboard({
    required Map<String, dynamic> userData,
    required Map<String, dynamic> onboardingData,
  }) async {
    final success = await registerUser(userData);
    if (!success) return false;

    final user = ref.read(userProvider);
    if (user == null) return false;

    final merged = {...onboardingData, "userId": user.id};

    return await submitOnboarding(merged);
  }

  /// 📥 Get partner details using ID
  Future<User?> getPartnerDetails(String partnerId) async {
    final api = ref.read(mendServiceProvider);
    try {
      final res = await api.getUser(partnerId);
      return User.fromJson(res.data);
    } catch (e) {
      print("Failed to fetch partner details: $e");
      return null;
    }
  }
}

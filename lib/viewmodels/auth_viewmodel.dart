import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mend_ai/models/user_model.dart';
import 'package:mend_ai/providers/mend_provider.dart';
import 'package:mend_ai/providers/user_provider.dart';

final authViewModelProvider = Provider((ref) => AuthViewModel(ref));

class AuthViewModel {
  final Ref ref;
  final _storage = const FlutterSecureStorage();

  AuthViewModel(this.ref);

  // ========== 🔐 LOGIN ==========
  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    try {
      final response = await ref
          .read(mendServiceProvider)
          .loginWithCredentials(email, password);

      await _handleLogin(
        response.data,
        saveCredentials: true,
        password: password,
      );
      return true;
    } catch (e) {
      print("[Login Error] $e");
      return false;
    }
  }

  // ========== 🔁 AUTO-LOGIN ==========
  Future<bool> tryAutoLogin() async {
    final email = await _storage.read(key: 'email');
    final password = await _storage.read(key: 'password');

    if (email == null || password == null) return false;

    try {
      final response = await ref
          .read(mendServiceProvider)
          .loginWithCredentials(email, password);

      await _handleLogin(response.data, password: password);
      return true;
    } catch (e) {
      print("[Auto-login Error] $e");
      return false;
    }
  }

  // ========== 👤 REGISTER ==========
  Future<bool> registerUser(
    Map<String, dynamic> userData,
    String password,
  ) async {
    try {
      final response = await ref
          .read(mendServiceProvider)
          .registerUser(userData);

      await _handleLogin(
        response.data,
        saveCredentials: true,
        password: password,
      );
      return true;
    } catch (e) {
      print("[Register Error] $e");
      return false;
    }
  }

  // ========== 🧠 ONBOARDING ==========
  Future<bool> submitOnboarding(Map<String, dynamic> onboardingData) async {
    try {
      await ref.read(mendServiceProvider).submitOnboarding(onboardingData);
      return true;
    } catch (e) {
      print("[Onboarding Error] $e");
      return false;
    }
  }

  // ========== COMBINED REGISTER + ONBOARD ==========
  Future<bool> registerAndOnboard({
    required Map<String, dynamic> userData,
    required Map<String, dynamic> onboardingData,
    required String password,
  }) async {
    final success = await registerUser(userData, password);
    if (!success) return false;

    final user = ref.read(userProvider);
    if (user == null) return false;

    final mergedData = {...onboardingData, "userId": user.id};
    return await submitOnboarding(mergedData);
  }

  // ========== 🔗 INVITE / LINK PARTNER ==========
  Future<bool> linkPartner(String yourId, String partnerId) async {
    try {
      final response = await ref.read(mendServiceProvider).invitePartner({
        "yourId": yourId,
        "partnerId": partnerId,
      });

      print("[Partner Link Success] ${response.data}");
      return true;
    } catch (e) {
      print("[Partner Link Error] $e");
      return false;
    }
  }

  // ========== 📥 FETCH PARTNER ==========
  Future<User?> getPartnerDetails(String partnerId) async {
    try {
      final response = await ref.read(mendServiceProvider).getUser(partnerId);
      return User.fromJson(response.data);
    } catch (e) {
      print("[Partner Fetch Error] $e");
      return null;
    }
  }

  // ========== 🔐 GOOGLE LOGIN ==========
  Future<bool> loginWithGoogle(
    GoogleSignInAccount googleUser,
    String password,
  ) async {
    try {
      final response = await ref.read(mendServiceProvider).loginWithGoogle({
        "email": googleUser.email,
        "name": googleUser.displayName ?? '',
        "googleId": googleUser.id,
      });

      await _handleLogin(response.data, password: password);

      // Mark for future auto-login
      await _storage.write(key: 'email', value: googleUser.email);
      await _storage.write(key: 'googleLogin', value: 'true');

      return true;
    } catch (e) {
      print("[Google Login Error] $e");
      return false;
    }
  }

  Future<void> logoutFromGoogle() async {
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      print("[Google SignOut Error] $e");
    }
    await logout();
  }

  // ========== 🚪 LOGOUT ==========
  Future<void> logout() async {
    await _storage.deleteAll();
    ref.read(userProvider.notifier).clearUser();
  }

  // ========== 🔁 HANDLE LOGIN (shared logic) ==========
  Future<void> _handleLogin(
    Map<String, dynamic> userData, {
    bool saveCredentials = false,
    required String password,
  }) async {
    final user = User.fromJson(userData);
    ref.read(userProvider.notifier).setUser(user);

    if (saveCredentials) {
      await _storage.write(key: 'email', value: user.email);
      await _storage.write(key: 'password', value: password);
    }
  }
}

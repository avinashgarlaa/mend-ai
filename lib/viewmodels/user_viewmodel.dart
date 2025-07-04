import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/models/user.dart';
import 'package:mend_ai/providers/mend_api_provider.dart';
import 'package:mend_ai/services/mend_api_service.dart';

final userViewModelProvider =
    StateNotifierProvider<UserViewModel, AsyncValue<User?>>((ref) {
      final api = ref.watch(mendApiServiceProvider);
      return UserViewModel(api);
    });

class UserViewModel extends StateNotifier<AsyncValue<User?>> {
  final MendApiService api;

  UserViewModel(this.api) : super(const AsyncValue.data(null));

  Future<void> registerUser(Map<String, dynamic> userData) async {
    state = const AsyncValue.loading();
    try {
      final user = await api.registerUser(userData);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> invitePartner(String yourId, String partnerId) async {
    try {
      final result = await api.invitePartner(yourId, partnerId);
      return result;
    } catch (_) {
      return false;
    }
  }
}

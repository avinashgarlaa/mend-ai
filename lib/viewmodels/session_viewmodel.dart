import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/models/session.dart';
import 'package:mend_ai/providers/mend_api_provider.dart';
import 'package:mend_ai/services/mend_api_service.dart';

final sessionViewModelProvider =
    StateNotifierProvider<SessionViewModel, AsyncValue<Session?>>((ref) {
      final api = ref.watch(mendApiServiceProvider);
      return SessionViewModel(api);
    });

class SessionViewModel extends StateNotifier<AsyncValue<Session?>> {
  final MendApiService api;

  SessionViewModel(this.api) : super(const AsyncValue.data(null));

  Future<void> startSession(Map<String, dynamic> sessionData) async {
    state = const AsyncValue.loading();
    try {
      final session = await api.startSession(sessionData);
      state = AsyncValue.data(session);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

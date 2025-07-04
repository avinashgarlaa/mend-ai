import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/services/mend_api_service.dart';
import 'package:mend_ai/providers/mend_api_provider.dart';

final chatViewModelProvider =
    StateNotifierProvider<ChatViewModel, AsyncValue<Map<String, dynamic>>>((
      ref,
    ) {
      final api = ref.watch(mendApiServiceProvider);
      return ChatViewModel(api);
    });

class ChatViewModel extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final MendApiService api;

  ChatViewModel(this.api) : super(const AsyncValue.data({}));

  Future<void> moderateChat(Map<String, String> chatData) async {
    state = const AsyncValue.loading();

    try {
      final response = await api.moderateChat(
        chatData,
      ); // this calls the backend
      state = AsyncValue.data(response);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    state = const AsyncValue.data({});
  }
}

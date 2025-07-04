import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/providers/mend_api_provider.dart';
import 'package:mend_ai/services/mend_api_service.dart';

final insightsViewModelProvider =
    StateNotifierProvider<InsightsViewModel, AsyncValue<Map<String, dynamic>>>((
      ref,
    ) {
      final api = ref.watch(mendApiServiceProvider);
      return InsightsViewModel(api);
    });

class InsightsViewModel
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final MendApiService api;

  InsightsViewModel(this.api) : super(const AsyncValue.data({}));

  Future<void> fetchInsights(String userId) async {
    state = const AsyncValue.loading();
    try {
      final insights = await api.getInsights(userId);
      state = AsyncValue.data(insights);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

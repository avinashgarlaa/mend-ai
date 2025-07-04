import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/models/reflection.dart';
import 'package:mend_ai/providers/mend_api_provider.dart';
import 'package:mend_ai/services/mend_api_service.dart';

final reflectionViewModelProvider =
    StateNotifierProvider<ReflectionViewModel, AsyncValue<Reflection?>>((ref) {
      final api = ref.watch(mendApiServiceProvider);
      return ReflectionViewModel(api);
    });

class ReflectionViewModel extends StateNotifier<AsyncValue<Reflection?>> {
  final MendApiService api;

  ReflectionViewModel(this.api) : super(const AsyncValue.data(null));

  Future<void> saveReflection(Map<String, dynamic> reflectionData) async {
    state = const AsyncValue.loading();
    try {
      final reflection = await api.saveReflection(reflectionData);
      state = AsyncValue.data(reflection);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

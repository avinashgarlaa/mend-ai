import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/providers/mend_api_provider.dart';
import 'package:mend_ai/services/mend_api_service.dart';
import 'package:mend_ai/viewmodels/user_viewmodel.dart';

/// State class for managing invite state
class InviteState {
  final String partnerId;
  final bool isLoading;

  InviteState({this.partnerId = '', this.isLoading = false});

  InviteState copyWith({String? partnerId, bool? isLoading}) {
    return InviteState(
      partnerId: partnerId ?? this.partnerId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// ViewModel for inviting a partner
class InviteViewModel extends StateNotifier<InviteState> {
  final MendApiService api;
  final Ref ref;

  InviteViewModel(this.api, this.ref) : super(InviteState());

  /// Sets the partner ID locally before sending
  void setPartnerId(String id) {
    state = state.copyWith(partnerId: id);
  }

  /// Sends the invite to the backend
  Future<bool> sendInvite() async {
    try {
      state = state.copyWith(isLoading: true);

      // Access user state from userViewModelProvider
      final userState = ref.read(userViewModelProvider);

      final yourId = userState.maybeWhen(
        data: (user) => user!.id,
        orElse: () => null,
      );

      if (yourId == null) {
        throw Exception('User ID not available');
      }

      // Call the API with your ID and partner's ID
      await api.sendInvite({"yourId": yourId, "partnerId": state.partnerId});

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }
}

/// Riverpod provider for the InviteViewModel
final inviteViewModelProvider =
    StateNotifierProvider<InviteViewModel, InviteState>((ref) {
      final api = ref.watch(mendApiServiceProvider);
      return InviteViewModel(api, ref);
    });

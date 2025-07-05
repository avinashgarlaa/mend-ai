// lib/viewmodels/session_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/models/session.dart';
import 'package:mend_ai/providers/mend_provider.dart';
import 'package:mend_ai/services/mend_service.dart';

class SessionViewModel extends StateNotifier<Session?> {
  final MendService api;
  SessionViewModel(this.api) : super(null);

  Future<Session?> startSession({
    required String partnerA,
    required String partnerB,
    String? initialContext,
  }) async {
    try {
      final res = await api.startSession({
        "partnerA": partnerA,
        "partnerB": partnerB,
        "initialContext": initialContext ?? "",
      });

      final session = Session.fromJson(res.data);

      return session;
    } catch (e) {
      print("Failed to start session: $e");
      return null;
    }
  }
}

final sessionViewModelProvider =
    StateNotifierProvider<SessionViewModel, Session?>(
      (ref) => SessionViewModel(ref.read(mendServiceProvider)),
    );

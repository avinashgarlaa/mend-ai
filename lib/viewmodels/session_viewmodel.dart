import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/models/session_model.dart';
import 'package:mend_ai/providers/mend_provider.dart';
import 'package:mend_ai/services/mend_service.dart';

class SessionViewModel extends StateNotifier<Session?> {
  final MendService api;
  SessionViewModel(this.api) : super(null);

  /// 🆕 Start a new session
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
      state = session;
      return session;
    } catch (e) {
      print("❌ Failed to start session: $e");
      return null;
    }
  }

  /// 🔍 Get the active session (unresolved)
  Future<Session?> getActiveSession(String userId) async {
    try {
      final res = await api.getActiveSession(userId);
      final session = Session.fromJson(res.data);
      state = session;
      return session;
    } catch (e) {
      print("⚠️ No active session: $e");
      state = null;
      return null;
    }
  }

  /// 🛑 End the session
  Future<bool> endSession(String sessionId) async {
    try {
      await api.endSession(sessionId);
      state = null;
      return true;
    } catch (e) {
      print("❌ Failed to end session: $e");
      return false;
    }
  }

  /// 🧠 Moderate chat message (GPT-4 AI)
  Future<Map<String, dynamic>> moderateChat(
    String transcript,
    String speakerId,
  ) async {
    try {
      final res = await api.moderateChat({
        "transcript": transcript,
        "context": "", // optional if needed
        "speaker": speakerId,
      });
      return res.data;
    } catch (e) {
      print("❌ Moderation failed: $e");
      return {"aiReply": "", "interrupt": false};
    }
  }

  /// 🧹 Clear current session
  void clearSession() {
    state = null;
  }
}

final sessionViewModelProvider =
    StateNotifierProvider<SessionViewModel, Session?>(
      (ref) => SessionViewModel(ref.read(mendServiceProvider)),
    );

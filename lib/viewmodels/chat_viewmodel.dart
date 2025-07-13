import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/services/mend_ws.dart';

final chatViewModelProvider = ChangeNotifierProvider<ChatViewModel>(
  (ref) => ChatViewModel(),
);

class ChatViewModel extends ChangeNotifier {
  final WebSocketService _wsService = WebSocketService();
  final List<String> _messages = [];
  final Dio _dio = Dio();

  StreamSubscription<String>? _subscription;
  bool _isConnected = false;

  int _userMessageCount = 0;
  bool _lastAskedToSelf = false;

  List<String> get messages => List.unmodifiable(_messages);
  bool get isConnected => _isConnected;

  void connect(String userId, String sessionId) {
    if (_isConnected) return;

    _wsService.connect(userId, sessionId);
    _isConnected = true;

    _subscription = _wsService.messages.listen(
      (msg) {
        _messages.add(msg);
        notifyListeners();
      },
      onError: (err) {
        debugPrint('WebSocket error: $err');
      },
      onDone: () {
        _isConnected = false;
        notifyListeners();
      },
    );

    notifyListeners();
  }

  Future<void> sendMessageWithModeration({
    required String speakerId,
    required String sessionId,
    required String text,
    Function(String reply)? onAIReply,
    Function()? onInterrupt,
  }) async {
    if (!_isConnected || text.trim().isEmpty) return;

    final cleanedText = text.trim();
    _userMessageCount++;

    // ✅ Send only — don't append locally
    _wsService.sendMessage(
      speakerId: speakerId,
      sessionId: sessionId,
      text: cleanedText,
    );

    try {
      final res = await _dio.post(
        'https://mend-backend-j0qd.onrender.com/api/moderate',
        data: {"transcript": cleanedText, "speaker": speakerId},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final aiReply = res.data['aiReply']?.toString();
      final interrupt = res.data['interrupt'];

      if (interrupt == true || interrupt == 'true') {
        if (onInterrupt != null) onInterrupt();
      }

      if (aiReply != null && aiReply.isNotEmpty) {
        final aiMessage = {
          "speakerId": "AI",
          "sessionId": sessionId,
          "text": aiReply,
          "timestamp": DateTime.now().millisecondsSinceEpoch,
        };

        _messages.add(jsonEncode(aiMessage));
        notifyListeners();

        if (onAIReply != null) onAIReply(aiReply);
      }

      if (interrupt != null && interrupt.isNotEmpty) {
        if (onInterrupt != null) onInterrupt();
      }

      if (_userMessageCount % 3 == 0) {
        await _askReflectiveQuestion(sessionId);
      }
    } catch (e) {
      debugPrint('❌ AI Moderation failed: $e');
    }
  }

  Future<void> _askReflectiveQuestion(String sessionId) async {
    final questions = [
      "Can you tell me a time when you felt truly heard?",
      "What does support from your partner look like?",
      "How would you like to feel more connected?",
      "What's something your partner does that you appreciate?",
      "How do you handle disagreements normally?",
      "What do you need from your partner right now?",
    ];

    final randomQuestion = (questions..shuffle()).first;
    final target = _lastAskedToSelf ? "your partner" : "you";
    final prompt = "To $target: $randomQuestion";
    _lastAskedToSelf = !_lastAskedToSelf;

    final aiMessage = {
      "speakerId": "AI",
      "sessionId": sessionId,
      "text": prompt,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    _messages.add(jsonEncode(aiMessage));
    notifyListeners();
  }

  void loadPreviousMessages(List<dynamic> messagesJson) {
    _messages.clear();
    for (final msg in messagesJson) {
      try {
        _messages.add(jsonEncode(msg));
      } catch (_) {
        debugPrint('⚠️ Invalid message skipped');
      }
    }
    notifyListeners();
  }

  void addMessage(String msg) {
    _messages.add(msg);
    notifyListeners();
  }

  void disconnect() {
    _subscription?.cancel();
    _wsService.disconnect();
    _messages.clear();
    _isConnected = false;
    notifyListeners();
  }
}

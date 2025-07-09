import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/services/mend_ws.dart';

/// 🔌 Riverpod provider
final chatViewModelProvider = ChangeNotifierProvider<ChatViewModel>(
  (ref) => ChatViewModel(),
);

class ChatViewModel extends ChangeNotifier {
  final WebSocketService _wsService = WebSocketService();
  final List<String> _messages = [];

  StreamSubscription<String>? _subscription;
  bool _isConnected = false;

  final Dio _dio = Dio(); // ✅ for moderation HTTP request

  /// 🧾 All messages (received and local)
  List<String> get messages => List.unmodifiable(_messages);

  /// 🔁 Realtime connection status
  bool get isConnected => _isConnected;

  /// 📡 Connect WebSocket
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

  /// 💬 Send structured JSON message with AI moderation
  Future<void> sendMessageWithModeration({
    required String speakerId,
    required String sessionId,
    required String text,
    required Function(String reply)? onAIReply,
    required Function()? onInterrupt,
  }) async {
    if (!_isConnected || text.trim().isEmpty) return;

    // Local echo
    final message = {
      "speakerId": speakerId,
      "sessionId": sessionId,
      "text": text.trim(),
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };
    _wsService.sendMessage(
      speakerId: speakerId,
      sessionId: sessionId,
      text: text.trim(),
    );
    _messages.add(jsonEncode(message));
    notifyListeners();

    try {
      final res = await _dio.post(
        'https://mend-backend-j0qd.onrender.com/api/moderate',
        data: {"transcript": text.trim(), "speaker": speakerId},
      );

      final aiReply = res.data['aiReply']?.toString();
      final interrupt = res.data['interrupt'] == true;

      if (aiReply != null && aiReply.isNotEmpty) {
        final aiMsg = {
          "speakerId": "AI",
          "sessionId": sessionId,
          "text": aiReply,
          "timestamp": DateTime.now().millisecondsSinceEpoch,
        };
        _messages.add(jsonEncode(aiMsg));
        notifyListeners();

        if (onAIReply != null) onAIReply(aiReply);
      }

      if (interrupt && onInterrupt != null) {
        onInterrupt();
      }
    } catch (e) {
      debugPrint("❌ Moderation failed: $e");
    }
  }

  /// ➕ Add message manually
  void addMessage(String msg) {
    _messages.add(msg);
    notifyListeners();
  }

  /// ❌ Disconnect WebSocket
  void disconnect() {
    _subscription?.cancel();
    _wsService.disconnect();
    _messages.clear();
    _isConnected = false;
    notifyListeners();
  }
}

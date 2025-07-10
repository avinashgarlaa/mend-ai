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
  final Dio _dio = Dio();

  StreamSubscription<String>? _subscription;
  bool _isConnected = false;

  /// 🧾 All chat messages
  List<String> get messages => List.unmodifiable(_messages);

  /// 🌐 WebSocket connection state
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

  /// 💬 Send message + get AI moderation from backend
  Future<void> sendMessageWithModeration({
    required String speakerId,
    required String sessionId,
    required String text,
    Function(String reply)? onAIReply,
    Function()? onInterrupt,
  }) async {
    if (!_isConnected || text.trim().isEmpty) return;

    final cleanedText = text.trim();

    // 🟦 Send to WebSocket
    _wsService.sendMessage(
      speakerId: speakerId,
      sessionId: sessionId,
      text: cleanedText,
    );

    final message = {
      "speakerId": speakerId,
      "sessionId": sessionId,
      "text": cleanedText,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };
    _messages.add(jsonEncode(message));
    notifyListeners();

    // 🌐 Call moderation API
    try {
      final res = await _dio.post(
        'https://mend-backend-j0qd.onrender.com/api/moderate',
        data: {"transcript": cleanedText, "speaker": speakerId},
      );

      final aiReply = res.data['aiReply']?.toString();
      final interrupt = res.data['interrupt']?.toString();

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

      if (interrupt != null && interrupt.isNotEmpty && onInterrupt != null) {
        onInterrupt();
      }
    } catch (e) {
      debugPrint('❌ AI Moderation failed: $e');
    }
  }

  /// 🧠 Preload historical messages
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

  /// ➕ Add single message manually
  void addMessage(String msg) {
    _messages.add(msg);
    notifyListeners();
  }

  /// 🔌 Disconnect and reset
  void disconnect() {
    _subscription?.cancel();
    _wsService.disconnect();
    _messages.clear();
    _isConnected = false;
    notifyListeners();
  }
}

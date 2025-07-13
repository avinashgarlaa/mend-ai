import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

/// 🧠 A robust singleton-style WebSocket handler for Mend
class WebSocketService {
  WebSocketChannel? _channel;
  String? _currentUserId;
  String? _currentSessionId;

  /// 🔗 Connect to the chat WebSocket with userId and sessionId
  void connect(String userId, String sessionId) {
    if (isConnected &&
        _currentUserId == userId &&
        _currentSessionId == sessionId) {
      print('[WebSocket] Already connected to session.');
      return;
    }

    disconnect(); // Always close any existing connection before creating a new one

    final uri = Uri.parse(
      'wss://mend-backend-j0qd.onrender.com/ws/$userId/$sessionId',
    );
    _channel = WebSocketChannel.connect(uri);
    _currentUserId = userId;
    _currentSessionId = sessionId;

    print('[WebSocket] ✅ Connected to $uri');
  }

  /// 💬 Send a structured message via WebSocket
  void sendMessage({
    required String speakerId,
    required String sessionId,
    required String text,
  }) {
    if (!isConnected) {
      print('[WebSocket] ❌ Cannot send. No active connection.');
      return;
    }

    final message = {
      "speakerId": speakerId,
      "sessionId": sessionId,
      "text": text.trim(),
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    try {
      _channel!.sink.add(jsonEncode(message));
      print('[WebSocket] 📤 Sent: $message');
    } catch (e) {
      print('[WebSocket] ❌ Error sending message: $e');
    }
  }

  /// 📥 Stream of incoming messages
  Stream<String> get messages {
    if (_channel == null) {
      throw Exception('[WebSocket] Not connected. Call connect() first.');
    }
    return _channel!.stream.cast<String>();
  }

  /// ❌ Gracefully close the WebSocket connection
  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.normalClosure);
      print('[WebSocket] 🔌 Disconnected.');
    }
    _channel = null;
    _currentUserId = null;
    _currentSessionId = null;
  }

  /// 🔄 WebSocket connection check
  bool get isConnected => _channel != null;
}

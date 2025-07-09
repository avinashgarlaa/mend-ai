import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

/// A singleton-like WebSocket handler for Mend
class WebSocketService {
  WebSocketChannel? _channel;

  /// 🔗 Connect using both userId and sessionId
  void connect(String userId, String sessionId) {
    if (isConnected) return; // Prevent duplicate connections

    final uri = Uri.parse(
      'wss://mend-backend-j0qd.onrender.com/ws/$userId/$sessionId',
    );
    _channel = WebSocketChannel.connect(uri);

    print('[WebSocket] Connected to $uri');
  }

  /// 💬 Send a structured JSON message
  void sendMessage({
    required String speakerId,
    required String sessionId,
    required String text,
  }) {
    if (!isConnected) {
      print('[WebSocket] Cannot send. Not connected.');
      return;
    }

    final message = {
      "speakerId": speakerId,
      "sessionId": sessionId,
      "text": text.trim(),
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    _channel!.sink.add(jsonEncode(message));
    print('[WebSocket] Sent: $message');
  }

  /// 📥 Listen to incoming messages (as string JSON)
  Stream<String> get messages {
    if (_channel == null) {
      throw Exception("WebSocket not connected. Call connect() first.");
    }
    return _channel!.stream.cast<String>();
  }

  /// ❌ Gracefully close the connection
  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.normalClosure);
      print('[WebSocket] Disconnected.');
    }
    _channel = null;
  }

  /// 🔄 Check WebSocket status
  bool get isConnected => _channel != null;
}

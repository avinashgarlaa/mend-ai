// lib/services/websocket_service.dart

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  late WebSocketChannel _channel;

  void connect(String userId) {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://mend-backend.onrender.com/ws/$userId'),
    );
  }

  void sendMessage(String text) {
    _channel.sink.add(text);
  }

  Stream get messages => _channel.stream;

  void disconnect() {
    _channel.sink.close();
  }
}

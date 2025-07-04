import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/models/chat.dart';

final chatHistoryProvider =
    StateNotifierProvider<ChatHistoryNotifier, List<ChatMessage>>(
      (ref) => ChatHistoryNotifier(),
    );

class ChatHistoryNotifier extends StateNotifier<List<ChatMessage>> {
  ChatHistoryNotifier() : super([]);

  void addMessage(ChatMessage msg) {
    state = [...state, msg];
  }

  void clearHistory() {
    state = [];
  }
}

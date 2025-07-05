class ChatMessage {
  final String speaker;
  final String message;
  final bool isAI;
  final bool isInterrupt;

  ChatMessage({
    required this.speaker,
    required this.message,
    this.isAI = false,
    this.isInterrupt = false,
  });
}

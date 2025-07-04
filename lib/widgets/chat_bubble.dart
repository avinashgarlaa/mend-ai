import 'package:flutter/material.dart';
import 'package:mend_ai/models/chat.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isAI = message.isAI;
    final isUserA = message.speaker.toLowerCase() == 'partnera';

    final bgColor = isAI
        ? Colors.grey.shade300
        : isUserA
        ? Colors.blue.shade100
        : Colors.pink.shade100;

    final alignment = isAI
        ? Alignment.center
        : isUserA
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isInterrupt ? Colors.red.shade100 : bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message.message, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

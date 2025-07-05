import 'package:flutter/material.dart';
import 'package:mend_ai/models/chat.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  Color _getSpeakerColor(String speaker, bool isAI, bool isInterrupt) {
    if (isInterrupt) return Colors.red.shade100;
    if (isAI) return Colors.grey.shade300;

    switch (speaker.toLowerCase()) {
      case 'partnera':
        return Colors.blue.shade50;
      case 'partnerb':
        return Colors.pink.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getSpeakerColor(
          message.speaker,
          message.isAI,
          message.isInterrupt,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${message.speaker}:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(message.message),
        ],
      ),
    );
  }
}

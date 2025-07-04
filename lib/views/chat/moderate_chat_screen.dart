import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/models/chat.dart';
import 'package:mend_ai/viewmodels/chat_viewmodel.dart';
import 'package:mend_ai/widgets/voice_chat_widget.dart';
import 'package:mend_ai/widgets/chat_bubble.dart';
import 'package:mend_ai/providers/chat_history_provider.dart';

class ModerateChatScreen extends ConsumerStatefulWidget {
  const ModerateChatScreen({super.key});

  @override
  ConsumerState<ModerateChatScreen> createState() => _ModerateChatScreenState();
}

class _ModerateChatScreenState extends ConsumerState<ModerateChatScreen> {
  final _transcriptController = TextEditingController();
  final _contextController = TextEditingController();
  final _speakerController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Listen to chat state and handle AI response
    ref.listen<AsyncValue<Map<String, dynamic>>>(chatViewModelProvider, (
      previous,
      next,
    ) {
      next.whenData((response) {
        ref
            .read(chatHistoryProvider.notifier)
            .addMessage(
              ChatMessage(
                speaker: 'AI',
                message: response['aiReply'] ?? 'No reply',
                isAI: true,
                isInterrupt: response['interrupt'] == true,
              ),
            );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);
    final chatVM = ref.read(chatViewModelProvider.notifier);
    final chatHistory = ref.watch(chatHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Moderated AI Chat')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "🗣️ Message Input:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _transcriptController,
              decoration: const InputDecoration(labelText: 'Transcript'),
              maxLines: 3,
            ),
            TextField(
              controller: _contextController,
              decoration: const InputDecoration(
                labelText: 'Context (Optional)',
              ),
            ),
            TextField(
              controller: _speakerController,
              decoration: const InputDecoration(
                labelText: 'Speaker (e.g., PartnerA)',
              ),
            ),
            const SizedBox(height: 20),
            chatState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () {
                      final transcript = _transcriptController.text.trim();
                      final contextText = _contextController.text.trim();
                      final speaker = _speakerController.text.trim();

                      if (transcript.isEmpty || speaker.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Transcript and Speaker are required',
                            ),
                          ),
                        );
                        return;
                      }

                      // Add user message to chat history
                      ref
                          .read(chatHistoryProvider.notifier)
                          .addMessage(
                            ChatMessage(
                              speaker: speaker,
                              message: transcript,
                              isAI: false,
                            ),
                          );

                      // Trigger AI moderation
                      chatVM.moderateChat({
                        'transcript': transcript,
                        'context': contextText,
                        'speaker': speaker,
                      });

                      _transcriptController.clear();
                    },
                    child: const Text('Send to AI'),
                  ),
            const SizedBox(height: 30),

            if (chatHistory.isNotEmpty) ...[
              const Text(
                "💬 Chat History:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...chatHistory.map((msg) => ChatBubble(message: msg)).toList(),
            ],

            const SizedBox(height: 32),
            const Text(
              "🎤 Or use voice instead:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            VoiceChatWidget(
              userId: _speakerController.text.isEmpty
                  ? 'partnerA'
                  : _speakerController.text,
              contextInfo: _contextController.text,
            ),
          ],
        ),
      ),
    );
  }
}

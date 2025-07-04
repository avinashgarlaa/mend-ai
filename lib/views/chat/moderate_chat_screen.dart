import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/viewmodels/chat_viewmodel.dart';

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
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);
    final chatVM = ref.read(chatViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Moderated AI Chat')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _transcriptController,
              decoration: const InputDecoration(labelText: 'Transcript'),
              maxLines: 3,
            ),
            TextField(
              controller: _contextController,
              decoration: const InputDecoration(labelText: 'Context'),
            ),
            TextField(
              controller: _speakerController,
              decoration: const InputDecoration(labelText: 'Speaker'),
            ),
            const SizedBox(height: 20),
            chatState.isLoading
                ? const CircularProgressIndicator()
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

                      chatVM.moderateChat({
                        'transcript': transcript,
                        'context': contextText,
                        'speaker': speaker,
                      });
                    },
                    child: const Text('Send for Moderation'),
                  ),
            const SizedBox(height: 20),
            chatState.when(
              data: (response) {
                if (response.isEmpty) {
                  return const SizedBox();
                }
                return Text(
                  'AI Reply: ${response['aiReply'] ?? 'No reply'}\n'
                  'Interrupt Warning: ${response['interrupt'] ?? 'None'}',
                );
              },
              loading: () => const SizedBox(),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

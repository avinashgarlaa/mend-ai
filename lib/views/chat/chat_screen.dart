import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/providers/user_provider.dart';
import 'package:mend_ai/viewmodels/chat_viewmodel.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  late stt.SpeechToText _speech;
  bool _isListening = false;

  late FlutterTts _flutterTts;
  Color _bgColor = Colors.white;

  @override
  void initState() {
    super.initState();

    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setPitch(1.1);
    _flutterTts.setSpeechRate(0.45);

    final user = ref.read(userProvider);
    final ws = ref.read(chatViewModelProvider);

    ws.connect(user?.id ?? "unknown");

    ws.messages.listen((message) {
      // Interruption signal
      if (message.startsWith("INTERRUPT:")) {
        _flashInterruptWarning();
        return;
      }

      setState(() {
        _messages.add(message);
      });

      // AI reply TTS
      if (message.startsWith("AI:")) {
        final aiReply = message.replaceFirst("AI:", "").trim();
        _flutterTts.speak(aiReply);
      }
    });
  }

  void _sendMessage([String? message]) {
    final ws = ref.read(chatViewModelProvider);
    final text = message ?? _controller.text.trim();
    if (text.isNotEmpty) {
      ws.sendMessage(text);
      _controller.clear();
    }
  }

  void _startListening() async {
    if (!_isListening) {
      final available = await _speech.initialize(
        onStatus: (status) => print('Speech status: $status'),
        onError: (error) => print('Speech error: $error'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              setState(() => _isListening = false);
              _sendMessage(result.recognizedWords);
              _speech.stop();
            }
          },
        );
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _flashInterruptWarning() {
    setState(() => _bgColor = Colors.red.shade100);
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() => _bgColor = Colors.white);
    });
  }

  @override
  void dispose() {
    ref.read(chatViewModelProvider).disconnect();
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Voice Chat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: _bgColor,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isSelf = message.startsWith("${user?.id}:");
                  final isAI = message.startsWith("AI:");
                  final text = message
                      .replaceFirst("${user?.id}:", "")
                      .replaceFirst("AI:", "")
                      .trim();

                  Color bubbleColor = Colors.grey.shade200;
                  if (isSelf) {
                    bubbleColor = user?.colorCode == "blue"
                        ? Colors.blue.shade100
                        : Colors.pink.shade100;
                  } else if (isAI) {
                    bubbleColor = Colors.amber.shade100;
                  } else {
                    bubbleColor = user?.colorCode == "blue"
                        ? Colors.pink.shade100
                        : Colors.blue.shade100;
                  }

                  final alignment = isSelf
                      ? Alignment.centerRight
                      : isAI
                      ? Alignment.center
                      : Alignment.centerLeft;

                  return Align(
                    alignment: alignment,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(text),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type or speak...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                    onPressed: _startListening,
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

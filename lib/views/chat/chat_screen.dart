import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mend_ai/providers/user_provider.dart';
import 'package:mend_ai/viewmodels/chat_viewmodel.dart';
import 'package:mend_ai/viewmodels/session_viewmodel.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  Color _bgColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _initVoice();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connectSocket());
  }

  void _initVoice() {
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts()
      ..setLanguage("en-US")
      ..setPitch(1.1)
      ..setSpeechRate(0.45);
  }

  void _connectSocket() {
    final user = ref.read(userProvider);
    final session = ref.read(sessionViewModelProvider);
    if (user != null && session != null) {
      final chatVM = ref.read(chatViewModelProvider);
      chatVM.connect(user.id, session.id);
      chatVM.addListener(_scrollToBottom);
    }
  }

  Future<void> _sendMessage([String? msg]) async {
    final user = ref.read(userProvider);
    final session = ref.read(sessionViewModelProvider);
    final chatVM = ref.read(chatViewModelProvider);
    final text = msg ?? _controller.text.trim();
    if (text.isEmpty || user == null || session == null) return;

    await chatVM.sendMessageWithModeration(
      speakerId: user.id,
      sessionId: session.id,
      text: text,
      onAIReply: (reply) async {
        await _flutterTts.speak(reply);
      },
      onInterrupt: _flashInterruptWarning,
    );

    _controller.clear();
  }

  void _startListening() async {
    if (!_isListening) {
      final available = await _speech.initialize(
        onStatus: (status) => debugPrint('Speech: $status'),
        onError: (error) => debugPrint('Speech error: $error'),
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

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _flashInterruptWarning() {
    setState(() => _bgColor = Colors.red.shade100);
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() => _bgColor = Colors.white);
    });
  }

  void _endSession() async {
    final session = ref.read(sessionViewModelProvider);
    if (session != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("End Session?"),
          content: const Text("Are you sure you want to end this session?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              child: const Text("End"),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await ref
            .read(sessionViewModelProvider.notifier)
            .endSession(session.id);
        if (mounted) Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    ref.read(chatViewModelProvider).disconnect();
    _speech.stop();
    _flutterTts.stop();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final messages = ref.watch(chatViewModelProvider).messages;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text("🗣️ Live Voice Chat"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.stop_circle_outlined),
            tooltip: "End Session",
            onPressed: _endSession,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: "Exit",
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final raw = messages[index];
                String text = raw;
                String? speaker;
                bool isSelf = false;
                bool isAI = false;

                try {
                  final parsed = jsonDecode(raw);
                  text = parsed['text'] ?? '';
                  speaker = parsed['speakerId'] ?? '';
                  isSelf = speaker == user?.id;
                  isAI = speaker == 'AI';
                } catch (_) {}

                final bgColor = isAI
                    ? Colors.amber.shade100
                    : isSelf
                    ? (user?.colorCode == "blue"
                          ? Colors.blue.shade100
                          : Colors.pink.shade100)
                    : (user?.colorCode == "blue"
                          ? Colors.pink.shade100
                          : Colors.blue.shade100);

                final alignment = isAI
                    ? Alignment.center
                    : isSelf
                    ? Alignment.centerRight
                    : Alignment.centerLeft;

                final nameLabel = isAI
                    ? "AI"
                    : isSelf
                    ? "You"
                    : "Partner";

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: 1,
                  child: Align(
                    alignment: alignment,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Chip(
                            label: Text(
                              nameLabel,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.deepPurple.shade100,
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 6),
                          Text(text, style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.Hm().format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.deepPurple,
                  ),
                  onPressed: _startListening,
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

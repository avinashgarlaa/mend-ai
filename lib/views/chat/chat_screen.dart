import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mend_ai/models/session_model.dart';
import 'package:mend_ai/models/user_model.dart';
import 'package:mend_ai/providers/user_provider.dart';
import 'package:mend_ai/viewmodels/auth_viewmodel.dart';
import 'package:mend_ai/viewmodels/chat_viewmodel.dart';
import 'package:mend_ai/viewmodels/session_viewmodel.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  Color _bgColor = const Color(0xfff0f4ff);

  User? partner;
  Session? session;

  final List<Color> gradientColors = [Color(0xff8e2de2), Color(0xff4a00e0)];

  @override
  void initState() {
    super.initState();
    _initVoice();
    _loadInitialData();
  }

  void _initVoice() {
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts()
      ..setLanguage("en-US")
      ..setPitch(1.1)
      ..setSpeechRate(0.45);
  }

  Future<void> _loadInitialData() async {
    final user = ref.read(userProvider);
    if (user == null || user.partnerId.isEmpty) return;

    final authVM = ref.read(authViewModelProvider);
    final sessionVM = ref.read(sessionViewModelProvider.notifier);

    try {
      final partnerRes = await authVM.getPartnerDetails(user.partnerId);
      final sessionRes = await sessionVM.getActiveSession(user.id);

      setState(() {
        partner = partnerRes;
        session = sessionRes;
      });

      if (sessionRes != null) {
        final chatVM = ref.read(chatViewModelProvider);
        chatVM.loadPreviousMessages(sessionRes.messages);
        chatVM.connect(user.id, sessionRes.id);
        chatVM.addListener(_scrollToBottom);

        Future.delayed(const Duration(milliseconds: 600), () {
          chatVM.sendMessageWithModeration(
            speakerId: "AI",
            sessionId: sessionRes.id,
            text:
                "Welcome to Mend. What would you like to work on together today?",
            onAIReply: (reply) => _flutterTts.speak(reply),
            onInterrupt: null,
          );
        });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load session or partner.")),
      );
    }
  }

  Future<void> _sendMessage([String? input]) async {
    final user = ref.read(userProvider);
    final chatVM = ref.read(chatViewModelProvider);
    final text = input ?? _controller.text.trim();

    if (text.isEmpty || user == null || session == null) return;

    await chatVM.sendMessageWithModeration(
      speakerId: user.id,
      sessionId: session!.id,
      text: text,
      onAIReply: (reply) async => await _flutterTts.speak(reply),
      onInterrupt: _flashInterruptWarning,
    );

    _controller.clear();
  }

  void _startListening() async {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    } else {
      final available = await _speech.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) => debugPrint('Speech error: $error'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              setState(() => _isListening = false);
              _sendMessage(result.recognizedWords);
            }
          },
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _flashInterruptWarning() {
    final partnerName = partner?.name ?? "your partner";
    setState(() => _bgColor = Colors.red.shade100);
    _flutterTts.speak("Please let $partnerName finish their thought.");
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() => _bgColor = const Color(0xfff0f4ff));
    });
  }

  void _endSession() async {
    if (session == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("End Session"),
        content: const Text("Are you sure you want to end this session?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("End"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ended = await ref
          .read(sessionViewModelProvider.notifier)
          .endSession(session!.id);

      if (ended && mounted) {
        Navigator.pushReplacementNamed(context, '/post-resolution');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to end session.")));
      }
    }
  }

  Widget _buildMessageBubble({
    required String text,
    required String label,
    required bool isSelf,
    required bool isAI,
    required bool isBlue,
    required int timestamp,
  }) {
    final color = isAI
        ? Colors.amber.shade100
        : isSelf
        ? (isBlue ? Colors.blue.shade100 : Colors.pink.shade100)
        : (isBlue ? Colors.pink.shade100 : Colors.blue.shade100);

    final align = isAI
        ? Alignment.center
        : isSelf
        ? Alignment.centerRight
        : Alignment.centerLeft;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isSelf ? 18 : 0),
      bottomRight: Radius.circular(isSelf ? 0 : 18),
    );

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 6),
            Text(text, style: GoogleFonts.lato(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              DateFormat.Hm().format(
                DateTime.fromMillisecondsSinceEpoch(timestamp),
              ),
              style: const TextStyle(fontSize: 10, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final messages = ref.watch(chatViewModelProvider).messages;

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                itemCount: messages.length,
                itemBuilder: (_, index) {
                  final raw = messages[index];
                  String text = raw;
                  String? speaker;
                  bool isSelf = false;
                  bool isAI = false;
                  int timestamp = DateTime.now().millisecondsSinceEpoch;

                  try {
                    final parsed = jsonDecode(raw);
                    text = parsed['text'] ?? '';
                    speaker = parsed['speakerId'];
                    timestamp = parsed['timestamp'] ?? timestamp;
                    isSelf = speaker == user?.id;
                    isAI = speaker == 'AI';
                  } catch (_) {}

                  final isBlue = user?.colorCode == 'blue';
                  final label = isAI
                      ? "AI"
                      : isSelf
                      ? user?.name ?? "You"
                      : partner?.name ?? "Partner";

                  return _buildMessageBubble(
                    text: text,
                    label: label,
                    isSelf: isSelf,
                    isAI: isAI,
                    isBlue: isBlue,
                    timestamp: timestamp,
                  );
                },
              ),
            ),

            // Input + Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: GoogleFonts.lato(),
                          decoration: InputDecoration(
                            hintText: "Type or speak...",
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            filled: true,
                            fillColor: const Color(0xfff0f0f0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: gradientColors.first,
                        ),
                        onPressed: _startListening,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.stop_circle_outlined),
                          onPressed: _endSession,
                          label: const Text("End Session"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.insights),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Insights coming soon..."),
                              ),
                            );
                          },
                          label: const Text("View Insights"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: gradientColors.first,
                            side: BorderSide(color: gradientColors.first),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_isListening)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

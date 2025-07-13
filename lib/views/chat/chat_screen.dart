// Enhanced ChatScreen with polished UI and AI-driven reflection
import 'dart:convert';
import 'dart:ui';
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
  bool _isSending = false;
  Color _bgColor = const Color(0xffe6f0ff);

  User? partner;
  Session? session;

  final List<Color> gradientColors = [
    const Color(0xffc2e9fb),
    const Color.fromARGB(255, 146, 187, 254),
  ];

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
        chatVM.removeListener(_scrollToBottom);
        chatVM.addListener(_scrollToBottom);
        chatVM.connect(user.id, sessionRes.id);

        Future.delayed(const Duration(milliseconds: 600), () {
          chatVM.sendMessageWithModeration(
            speakerId: "AI",
            sessionId: sessionRes.id,
            text: "Welcome to Mend. What would you like to work on today?",
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
    if (_isSending) return;
    final user = ref.read(userProvider);
    final chatVM = ref.read(chatViewModelProvider);
    final text = input ?? _controller.text.trim();

    if (text.isEmpty || user == null || session == null) return;

    _isSending = true;

    await chatVM.sendMessageWithModeration(
      speakerId: user.id,
      sessionId: session!.id,
      text: text,
      onAIReply: (reply) async => await _flutterTts.speak(reply),
      onInterrupt: _flashInterruptWarning,
    );

    _controller.clear();
    _isSending = false;
  }

  void _startListening() async {
    if (_isListening || _speech.isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final available = await _speech.initialize();
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
      setState(() => _bgColor = const Color(0xffe6f0ff));
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
        ? Colors.yellow.shade100
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

    return AnimatedAlign(
      alignment: align,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color, borderRadius: borderRadius),
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

    final partnerName = partner?.name ?? "Partner";
    final userName = user?.name ?? "You";

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xffc2e9fb),
                  Color(0xffa1c4fd),
                  Color(0xffcfd9df),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white.withOpacity(0.35),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Chat with $partnerName",
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[900],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert_rounded),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
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
                            ? "Therapist AI"
                            : isSelf
                            ? userName
                            : partnerName;

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
                ),
                _buildInputSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 26),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.blueGrey.withOpacity(0.1),
                          width: 1.1,
                        ),
                      ),
                      padding: const EdgeInsets.only(left: 16),
                      child: TextField(
                        controller: _controller,
                        cursorColor: gradientColors.first,
                        style: GoogleFonts.lato(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: "Type your thoughts...",
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.emoji_emotions_outlined,
                              color: Colors.grey.shade400,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Tooltip(
                    message: _isListening ? "Listening..." : "Speak",
                    child: GestureDetector(
                      onTap: _startListening,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening
                              ? Colors.redAccent
                              : Colors.white.withOpacity(0.9),
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening
                              ? Colors.white
                              : Colors.blueAccent.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Tooltip(
                    message: "Send message",
                    child: GestureDetector(
                      onTap: _sendMessage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              const Color.fromARGB(255, 102, 139, 205),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.7),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.insights_outlined),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/insights'),
                      label: Text(
                        "View Insights",
                        style: GoogleFonts.aBeeZee(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: gradientColors.first,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class VoiceChatWidget extends ConsumerStatefulWidget {
  final String userId;
  final String contextInfo;
  const VoiceChatWidget({
    super.key,
    required this.userId,
    required this.contextInfo,
  });

  @override
  ConsumerState<VoiceChatWidget> createState() => _VoiceChatWidgetState();
}

class _VoiceChatWidgetState extends ConsumerState<VoiceChatWidget> {
  final recorder = FlutterSoundRecorder();
  bool isRecording = false;
  String? transcript;
  String? aiResponse;

  @override
  void initState() {
    super.initState();
    initRecorder();
  }

  Future<void> initRecorder() async {
    await Permission.microphone.request();
    await recorder.openRecorder();
  }

  Future<void> startRecording() async {
    setState(() => isRecording = true);
    await recorder.startRecorder(toFile: 'audio.aac');
  }

  Future<void> stopRecording() async {
    final path = await recorder.stopRecorder();
    setState(() => isRecording = false);

    if (path == null) return;

    // Mock transcript instead of Whisper
    transcript = "My partner never listens during arguments.";

    // Send to /api/moderate
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/moderate'),
      headers: {'Content-Type': 'application/json'},
      body:
          '''
      {
        "transcript": "${transcript!}",
        "context": "${widget.contextInfo}",
        "speaker": "${widget.userId}"
      }
      ''',
    );

    if (response.statusCode == 200) {
      setState(() {
        aiResponse = response.body.contains("aiReply")
            ? RegExp(
                r'"aiReply"\s*:\s*"([^"]+)"',
              ).firstMatch(response.body)?.group(1)
            : "Error parsing response";
      });
    } else {
      setState(() => aiResponse = "Failed to get response");
    }
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        isRecording
            ? const Icon(Icons.mic, size: 64, color: Colors.red)
            : const Icon(Icons.mic_none, size: 64, color: Colors.grey),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: isRecording ? stopRecording : startRecording,
          child: Text(isRecording ? "Stop & Send" : "Start Talking"),
        ),
        const SizedBox(height: 20),
        if (aiResponse != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text("🧠 AI says: $aiResponse"),
          ),
      ],
    );
  }
}

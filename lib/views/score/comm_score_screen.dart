import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/providers/mend_provider.dart';
import '../../providers/user_provider.dart';

class ScoreScreen extends ConsumerStatefulWidget {
  const ScoreScreen({super.key});

  @override
  ConsumerState<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends ConsumerState<ScoreScreen> {
  final _scores = {
    "empathy": 5,
    "listening": 5,
    "clarity": 5,
    "respect": 5,
    "responsiveness": 5,
    "openMindedness": 5,
  };

  void _submit() async {
    final user = ref.read(userProvider);
    final api = ref.read(mendServiceProvider);

    if (user == null || user.currentSessionId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Missing user/session")));
      return;
    }

    final payload = {
      ..._scores,
      "userId": user.id,
      "sessionId": user.currentSessionId,
    };

    try {
      await api.submitScore(payload);
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildSlider(String label, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: _scores[key]!.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: _scores[key].toString(),
          onChanged: (val) {
            setState(() {
              _scores[key] = val.toInt();
            });
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Communication Score")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildSlider("Empathy", "empathy"),
            _buildSlider("Listening", "listening"),
            _buildSlider("Clarity", "clarity"),
            _buildSlider("Respect", "respect"),
            _buildSlider("Responsiveness", "responsiveness"),
            _buildSlider("Open-Mindedness", "openMindedness"),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("Finish & Go to Dashboard"),
            ),
          ],
        ),
      ),
    );
  }
}

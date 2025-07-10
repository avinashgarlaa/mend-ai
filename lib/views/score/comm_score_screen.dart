import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mend_ai/providers/mend_provider.dart';
import '../../providers/user_provider.dart';

class ScoreScreen extends ConsumerStatefulWidget {
  const ScoreScreen({super.key});

  @override
  ConsumerState<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends ConsumerState<ScoreScreen> {
  final Map<String, int> _scores = {
    "empathy": 5,
    "listening": 5,
    "clarity": 5,
    "respect": 5,
    "responsiveness": 5,
    "openMindedness": 5,
  };

  bool _isSubmitting = false;

  final Map<String, IconData> _icons = {
    "empathy": Icons.favorite_outline,
    "listening": Icons.hearing_outlined,
    "clarity": Icons.lightbulb_outline,
    "respect": Icons.volunteer_activism_outlined,
    "responsiveness": Icons.reply_outlined,
    "openMindedness": Icons.public_outlined,
  };

  final Map<String, String> _labels = {
    "empathy": "Empathy",
    "listening": "Listening",
    "clarity": "Clarity",
    "respect": "Respect",
    "responsiveness": "Responsiveness",
    "openMindedness": "Open-Mindedness",
  };

  void _submit() async {
    final user = ref.read(userProvider);
    final api = ref.read(mendServiceProvider);

    if (user == null || user.currentSessionId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Missing user or session.")));
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = {
      "sessionId": user.currentSessionId!,
      "partnerId": user.id,
      ..._scores,
    };

    try {
      await api.submitScore(payload);
      if (mounted) Navigator.pushNamed(context, '/celebrate');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildScoreSlider(String key) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_icons[key], color: Colors.deepPurple),
                const SizedBox(width: 12),
                Text(
                  _labels[key]!,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  "${_scores[key]} / 10",
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.deepPurple,
                inactiveTrackColor: Colors.deepPurple.shade100,
                thumbColor: Colors.deepPurple,
                overlayColor: Colors.deepPurple.withOpacity(0.2),
                trackHeight: 4,
              ),
              child: Slider(
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xfffdfbff), Color(0xffeceaff)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Communication Reflection",
                  style: GoogleFonts.lato(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "How did you feel about your communication in this session?",
                  style: GoogleFonts.lato(fontSize: 15, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              ..._scores.keys.map(_buildScoreSlider),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    _isSubmitting ? "Submitting..." : "Submit & Celebrate",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: GoogleFonts.lato(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

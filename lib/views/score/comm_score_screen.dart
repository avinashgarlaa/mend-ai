import 'dart:ui';
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
  Map<String, int> _scores = {};
  String? _summary;
  bool _isLoading = true;

  final Map<String, IconData> _icons = {
    "empathy": Icons.favorite_outline,
    "listening": Icons.hearing_outlined,
    "clarity": Icons.lightbulb_outline,
    "respect": Icons.volunteer_activism_outlined,
    "conflictResolution": Icons.handshake_outlined,
  };

  final Map<String, String> _labels = {
    "empathy": "Empathy",
    "listening": "Listening",
    "clarity": "Clarity",
    "respect": "Respect",
    "conflictResolution": "Conflict Resolution",
  };

  @override
  void initState() {
    super.initState();
    _loadScore();
  }

  Future<void> _loadScore() async {
    final user = ref.read(userProvider);
    final api = ref.read(mendServiceProvider);

    if (user == null || user.currentSessionId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final res = await api.getSessionScore(user.currentSessionId!);
      final session = res.data;
      final scoreField = (session['partnerB'] == user.id) ? 'scoreB' : 'scoreA';
      final score = session[scoreField];

      if (score != null && score is Map<String, dynamic>) {
        setState(() {
          _scores = {
            for (final key in _labels.keys)
              if (score[key] != null && score[key] is int) key: score[key],
          };
          _summary = score["summary"];
        });
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching AI score: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildGlassHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Center(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.montserrat(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: "AI ",
                    style: GoogleFonts.aBeeZee(color: Colors.black87),
                  ),
                  TextSpan(
                    text: "Communication Score",
                    style: GoogleFonts.aBeeZee(color: Colors.blueAccent),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final themeColor = Colors.deepPurple;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xffc2e9fb),
                        Color(0xffa1c4fd),
                        Color(0xffcfd9df),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SizedBox.expand(),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 36, 20, 48),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGlassHeader(),
                              const SizedBox(height: 20),
                              Text(
                                "These insights were generated based on your latest session:",
                                style: GoogleFonts.aBeeZee(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (_summary != null)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    _summary!,
                                    style: GoogleFonts.aBeeZee(
                                      fontSize: 16,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              ..._scores.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _icons[entry.key],
                                        color: Colors.blueAccent,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _labels[entry.key]!,
                                          style: GoogleFonts.lato(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "${entry.value} / 5",
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 40),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/celebrate',
                                      ),
                                  icon: const Icon(
                                    Icons.celebration,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    "Continue to Celebrate ",
                                    style: GoogleFonts.aBeeZee(
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

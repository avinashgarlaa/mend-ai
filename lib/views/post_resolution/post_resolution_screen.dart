import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mend_ai/providers/mend_provider.dart';
import '../../providers/user_provider.dart';

class PostResolutionScreen extends ConsumerStatefulWidget {
  const PostResolutionScreen({super.key});

  @override
  ConsumerState<PostResolutionScreen> createState() =>
      _PostResolutionScreenState();
}

class _PostResolutionScreenState extends ConsumerState<PostResolutionScreen> {
  final gratitudeController = TextEditingController();
  final sharedFeelingsController = TextEditingController();
  int attachmentScore = 3;
  bool _isSubmitting = false;

  void _submit() async {
    final user = ref.read(userProvider);
    final api = ref.read(mendServiceProvider);

    if (user == null || user.currentSessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User or session ID is missing.")),
      );
      return;
    }

    final gratitude = gratitudeController.text.trim();
    final sharedFeelings = sharedFeelingsController.text.trim();

    if (gratitude.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in the gratitude section.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = {
      "userId": user.id,
      "sessionId": user.currentSessionId,
      "gratitude": gratitude,
      if (sharedFeelings.isNotEmpty) "sharedFeelings": sharedFeelings,
      "attachmentScore": attachmentScore,
    };

    try {
      await api.submitPostResolution(payload);
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Reflection Saved"),
          content: const Text("Thank you for your honest reflection."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/reflection'),
              child: const Text("Continue"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildGlassHeader(BuildContext context, WidgetRef ref) {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // IconButton(
              //   icon: const Icon(
              //     Icons.arrow_back_ios_new_rounded,
              //     color: Colors.black54,
              //   ),
              //   onPressed: () => Navigator.pushNamed(context, "/home"),
              // ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.montserrat(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "Post-Session ",
                      style: GoogleFonts.aBeeZee(color: Colors.black87),
                    ),
                    TextSpan(
                      text: "Reflection",
                      style: GoogleFonts.aBeeZee(color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
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
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGlassHeader(context, ref),

                        const SizedBox(height: 20),

                        _buildSectionTitle("  1. Gratitude"),
                        _buildPromptField(
                          hint:
                              "What did your partner do that you appreciated?",
                          controller: gratitudeController,
                        ),

                        const SizedBox(height: 24),
                        _buildSectionTitle("  2. Shared Feelings (Optional)"),
                        _buildPromptField(
                          hint: "Anything emotional you'd like to share?",
                          controller: sharedFeelingsController,
                        ),

                        const SizedBox(height: 24),
                        _buildSectionTitle("  3. Attachment Score (1–5)"),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.blueAccent,
                            inactiveTrackColor: Colors.white30,
                            trackHeight: 6,
                            thumbColor: Colors.blueAccent,
                            overlayColor: Colors.blueAccent.withOpacity(0.2),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 18,
                            ),
                            valueIndicatorShape:
                                const PaddleSliderValueIndicatorShape(),
                            valueIndicatorColor: const Color.fromRGBO(
                              68,
                              138,
                              255,
                              1,
                            ),
                            valueIndicatorTextStyle: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          child: Slider(
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: attachmentScore.toString(),
                            value: attachmentScore.toDouble(),
                            onChanged: (val) {
                              setState(() => attachmentScore = val.toInt());
                            },
                          ),
                        ),

                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : _submit,
                            icon: Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                            ),
                            label: _isSubmitting
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    "Save Reflection",
                                    style: GoogleFonts.aBeeZee(
                                      color: Colors.white,
                                    ),
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.aBeeZee(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildPromptField({
    required String hint,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      maxLines: 4,
      style: GoogleFonts.lato(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade700),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

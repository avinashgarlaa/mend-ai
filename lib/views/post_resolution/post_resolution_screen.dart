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
  final reflectionController = TextEditingController();
  final bondingController = TextEditingController();

  bool _isSubmitting = false;

  void _submit() async {
    final user = ref.read(userProvider);
    final api = ref.read(mendServiceProvider);

    if (user == null) return;

    final gratitude = gratitudeController.text.trim();
    final reflection = reflectionController.text.trim();
    final bonding = bondingController.text.trim();

    if (gratitude.isEmpty || reflection.isEmpty || bonding.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = {
      "userId": user.id,
      "sessionId": user.currentSessionId ?? "",
      "gratitude": gratitude,
      "reflection": reflection,
      "bondingActivity": bonding,
    };

    try {
      await api.submitPostResolution(payload);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Reflection saved.")));
        Navigator.pushNamed(context, '/reflection'); // Adjust route if needed
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xfff5f7fa), Color(0xffe0ecff)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Let’s reflect on your session",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                _buildSectionTitle("1. Express Gratitude"),
                _buildPromptField(
                  hint: "What did your partner do that you appreciated?",
                  controller: gratitudeController,
                ),
                const SizedBox(height: 30),

                _buildSectionTitle("2. Personal Reflection"),
                _buildPromptField(
                  hint: "What’s something meaningful you learned today?",
                  controller: reflectionController,
                ),
                const SizedBox(height: 30),

                _buildSectionTitle("3. Suggest a Bonding Activity"),
                _buildPromptField(
                  hint: "Suggest something fun or meaningful to do together.",
                  controller: bondingController,
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: GoogleFonts.lato(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          )
                        : const Text("Continue to Reflection"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade800,
          ),
        ),
        const SizedBox(height: 6),
        Container(height: 2, width: 60, color: Colors.deepPurple.shade200),
        const SizedBox(height: 12),
      ],
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
        hintStyle: const TextStyle(color: Colors.black45),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

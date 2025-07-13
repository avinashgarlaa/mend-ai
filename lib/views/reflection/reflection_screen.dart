import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mend_ai/providers/mend_provider.dart';
import '../../providers/user_provider.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key});

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final TextEditingController controller = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoading = true;
  bool _alreadySubmitted = false;

  @override
  void initState() {
    super.initState();
    _loadReflection();
  }

  Future<void> _loadReflection() async {
    final user = ref.read(userProvider);
    final api = ref.read(mendServiceProvider);

    if (user == null || user.currentSessionId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await api.getReflection(user.id, user.currentSessionId!);
      if (response.statusCode == 200 && response.data != null) {
        final reflectionText = response.data['text'] ?? "";
        if (reflectionText.isNotEmpty) {
          controller.text = reflectionText;
          _alreadySubmitted = true;
        }
      }
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    final user = ref.read(userProvider);
    final api = ref.read(mendServiceProvider);

    if (user == null || user.currentSessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing user or session ID.")),
      );
      return;
    }

    final trimmedText = controller.text.trim();
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final payload = {
      "userId": user.id,
      "sessionId": user.currentSessionId,
      "text": trimmedText,
    };

    try {
      final response = await api.submitReflection(payload);
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/score');
        }
      } else {
        throw Exception("Submission failed");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Submission failed: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
                    text: "Personal ",
                    style: GoogleFonts.aBeeZee(color: Colors.black87),
                  ),
                  TextSpan(
                    text: "Reflection",
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

  Widget _buildPromptField() {
    return TextField(
      controller: controller,
      maxLines: 6,
      style: GoogleFonts.lato(fontSize: 15),
      decoration: InputDecoration(
        hintText: "Write your reflection here… (Leave blank for AI suggestion)",
        hintStyle: const TextStyle(color: Colors.black45),
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

  @override
  Widget build(BuildContext context) {
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
                              const SizedBox(height: 24),
                              Text(
                                " -> What did you learn about yourself or \n your partner?",
                                style: GoogleFonts.aBeeZee(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildPromptField(),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isSubmitting ? null : _submit,
                                  icon: const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    _isSubmitting
                                        ? "Submitting..."
                                        : (_alreadySubmitted
                                              ? "Update Reflection"
                                              : "Submit Reflection"),
                                    style: GoogleFonts.aBeeZee(
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
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
}

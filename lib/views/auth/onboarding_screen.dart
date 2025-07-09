// lib/views/onboarding_questionnaire_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mend_ai/providers/user_provider.dart';
import 'package:mend_ai/viewmodels/auth_viewmodel.dart';

class OnboardingQuestionnaireScreen extends ConsumerStatefulWidget {
  const OnboardingQuestionnaireScreen({super.key});

  @override
  ConsumerState<OnboardingQuestionnaireScreen> createState() =>
      _OnboardingQuestionnaireScreenState();
}

class _OnboardingQuestionnaireScreenState
    extends ConsumerState<OnboardingQuestionnaireScreen> {
  final Set<String> selectedGoals = {};
  final Set<String> selectedChallenges = {};
  final TextEditingController otherGoalController = TextEditingController();
  final TextEditingController otherChallengeController =
      TextEditingController();

  final List<String> goals = [
    "Communication",
    "Conflict resolution",
    "Intimacy",
    "Trust",
    "Shared decision-making",
    "Other",
  ];

  final List<String> challenges = [
    "Frequent arguments",
    "Feeling unheard",
    "Lack of quality time",
    "Financial stress",
    "Parenting differences",
    "Loss of intimacy",
    "External pressures",
    "Other",
  ];

  void _submit() async {
    final user = ref.read(userProvider);
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not found")));
      return;
    }

    final payload = {
      "userId": user.id, // ✅ fixed here
      "goals": selectedGoals.toList(),
      "otherGoal": otherGoalController.text.trim(),
      "challenges": selectedChallenges.toList(),
      "otherChallenge": otherChallengeController.text.trim(),
    };

    print(payload);

    final success = await ref
        .read(authViewModelProvider)
        .submitOnboarding(payload);
    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Submission failed")));
    }
  }

  Widget _buildChipSection({
    required String title,
    required IconData icon,
    required List<String> items,
    required Set<String> selectedSet,
    required TextEditingController otherController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.laila(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) {
            return FilterChip(
              label: Text(item),
              selected: selectedSet.contains(item),
              onSelected: (val) {
                setState(() {
                  val ? selectedSet.add(item) : selectedSet.remove(item);
                });
              },
              selectedColor: Colors.deepPurple,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: selectedSet.contains(item) ? Colors.white : Colors.black,
              ),
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }).toList(),
        ),
        if (selectedSet.contains("Other"))
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextField(
              controller: otherController,
              decoration: const InputDecoration(
                hintText: "Other (please specify)",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f4ff),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Let's personalize your experience",
                style: GoogleFonts.laila(
                  color: Colors.deepPurple,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ListView(
                    children: [
                      _buildChipSection(
                        title: "What would you like to improve?",
                        icon: Icons.favorite_border,
                        items: goals,
                        selectedSet: selectedGoals,
                        otherController: otherGoalController,
                      ),
                      const SizedBox(height: 32),
                      _buildChipSection(
                        title: "What challenges are you facing?",
                        icon: Icons.warning_amber_outlined,
                        items: challenges,
                        selectedSet: selectedChallenges,
                        otherController: otherChallengeController,
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: Icon(
                            Icons.navigate_next,
                            color: Colors.white,
                            size: 30,
                          ),
                          label: Text(
                            "Continue",
                            style: GoogleFonts.varela(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.deepPurple,
                            textStyle: const TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
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

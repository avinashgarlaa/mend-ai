// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      "userId": user.id,
      "relationshipGoals": selectedGoals.toList(),
      "otherGoal": otherGoalController.text.trim(),
      "currentChallenges": selectedChallenges.toList(),
      "otherChallenge": otherChallengeController.text.trim(),
    };

    final success = await ref
        .read(authViewModelProvider)
        .submitOnboarding(payload);
    if (success) {
      Navigator.pushReplacementNamed(context, '/invite-partner');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Submission failed")));
    }
  }

  Widget _buildChipSection({
    required String title,
    required List<String> items,
    required Set<String> selectedSet,
    required TextEditingController otherController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: items.map((item) {
            return FilterChip(
              label: Text(item),
              selected: selectedSet.contains(item),
              onSelected: (val) {
                setState(() {
                  val ? selectedSet.add(item) : selectedSet.remove(item);
                });
              },
              selectedColor: Colors.deepPurple.shade200,
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
      appBar: AppBar(
        title: const Text("Your Relationship Goals"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            _buildChipSection(
              title: "✨ What do you want to improve?",
              items: goals,
              selectedSet: selectedGoals,
              otherController: otherGoalController,
            ),
            const SizedBox(height: 32),
            _buildChipSection(
              title: "⚠️ What challenges are you facing?",
              items: challenges,
              selectedSet: selectedChallenges,
              otherController: otherChallengeController,
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Continue"),
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
    );
  }
}

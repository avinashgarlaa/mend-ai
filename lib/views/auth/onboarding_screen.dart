// lib/views/onboarding_questionnaire_screen.dart

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
        .submitOnboardingOnly(payload);
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: items.map((item) {
            return FilterChip(
              label: Text(item),
              selected: selectedSet.contains(item),
              onSelected: (val) {
                setState(() {
                  val ? selectedSet.add(item) : selectedSet.remove(item);
                });
              },
            );
          }).toList(),
        ),
        if (selectedSet.contains("Other"))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextField(
              controller: otherController,
              decoration: const InputDecoration(
                hintText: "Other (please specify)",
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Relationship Goals")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            _buildChipSection(
              title: "What do you want to improve?",
              items: goals,
              selectedSet: selectedGoals,
              otherController: otherGoalController,
            ),
            const SizedBox(height: 32),
            _buildChipSection(
              title: "What challenges are you facing?",
              items: challenges,
              selectedSet: selectedChallenges,
              otherController: otherChallengeController,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.navigate_next),
              label: const Text("Continue"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

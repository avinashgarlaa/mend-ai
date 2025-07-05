import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/viewmodels/onboarding_viewmodel.dart';

class OnboardingQuestionnaireScreen extends ConsumerStatefulWidget {
  const OnboardingQuestionnaireScreen({super.key});

  @override
  ConsumerState<OnboardingQuestionnaireScreen> createState() =>
      _OnboardingQuestionnaireScreenState();
}

class _OnboardingQuestionnaireScreenState
    extends ConsumerState<OnboardingQuestionnaireScreen> {
  final nameController = TextEditingController();
  final otherGoalController = TextEditingController();
  final otherChallengeController = TextEditingController();
  String selectedGender = 'Male';

  final List<String> goals = [
    'Communication',
    'Conflict resolution',
    'Intimacy',
    'Trust',
    'Shared decision-making',
    'Other',
  ];

  final List<String> challenges = [
    'Frequent arguments',
    'Feeling unheard or misunderstood',
    'Lack of quality time',
    'Financial stress',
    'Parenting differences',
    'Loss of intimacy',
    'External pressures',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(onboardingViewModelProvider.notifier);
    final selected = ref.watch(onboardingViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Personalize Your Experience")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Your Name"),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Enter your name'),
          ),
          const SizedBox(height: 16),

          const Text("Gender"),
          DropdownButton<String>(
            value: selectedGender,
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (value) {
              setState(() {
                selectedGender = value!;
              });
            },
          ),
          const Divider(height: 32),

          const Text("Relationship Goals (Select multiple)"),
          ...goals.map((goal) {
            final isOther = goal == 'Other';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  value: selected.goals.contains(goal),
                  title: Text(goal),
                  onChanged: (val) {
                    vm.toggleGoal(goal);
                  },
                ),
                if (isOther && selected.goals.contains('Other'))
                  TextField(
                    controller: otherGoalController,
                    decoration: const InputDecoration(
                      hintText: 'Enter other goal',
                    ),
                  ),
              ],
            );
          }),
          const Divider(height: 32),

          const Text("Current Challenges (Select multiple)"),
          ...challenges.map((challenge) {
            final isOther = challenge == 'Other';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  value: selected.challenges.contains(challenge),
                  title: Text(challenge),
                  onChanged: (val) {
                    vm.toggleChallenge(challenge);
                  },
                ),
                if (isOther && selected.challenges.contains('Other'))
                  TextField(
                    controller: otherChallengeController,
                    decoration: const InputDecoration(
                      hintText: 'Enter other challenge',
                    ),
                  ),
              ],
            );
          }),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter your name")),
                );
                return;
              }

              vm.submitOnboardingData(
                name: nameController.text.trim(),
                gender: selectedGender,
                otherGoal: otherGoalController.text.trim(),
                otherChallenge: otherChallengeController.text.trim(),
              );

              Navigator.pushNamed(context, '/invite-partner');
            },
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }
}

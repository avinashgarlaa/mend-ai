import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestionnaireScreen extends ConsumerStatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  ConsumerState<QuestionnaireScreen> createState() =>
      _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends ConsumerState<QuestionnaireScreen> {
  final nameController = TextEditingController();
  String? selectedGender;

  final List<String> goals = [
    'Communication',
    'Conflict resolution',
    'Intimacy',
    'Trust',
    'Shared decision-making',
  ];
  final List<String> challenges = [
    'Frequent arguments',
    'Feeling unheard or misunderstood',
    'Lack of quality time together',
    'Financial stress',
    'Parenting differences',
    'Loss of intimacy',
    'External pressures',
  ];

  final Set<String> selectedGoals = {};
  final Set<String> selectedChallenges = {};
  final TextEditingController goalOtherController = TextEditingController();
  final TextEditingController challengeOtherController =
      TextEditingController();

  void _onSubmit() {
    final name = nameController.text.trim();
    if (name.isEmpty || selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill name and select gender.')),
      );
      return;
    }

    final data = {
      'name': name,
      'gender': selectedGender,
      'goals': selectedGoals.toList() + [goalOtherController.text],
      'challenges':
          selectedChallenges.toList() + [challengeOtherController.text],
    };

    // For now, just print and navigate
    print(data);
    Navigator.pushNamed(context, '/invite-partner');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About You')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(controller: nameController),
            const SizedBox(height: 16),

            const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: ['Male', 'Female', 'Other'].map((gender) {
                return ChoiceChip(
                  label: Text(gender),
                  selected: selectedGender == gender,
                  onSelected: (_) => setState(() => selectedGender = gender),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            const Text(
              'What do you want to improve?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 10,
              children: goals.map((goal) {
                return FilterChip(
                  label: Text(goal),
                  selected: selectedGoals.contains(goal),
                  onSelected: (val) {
                    setState(() {
                      val
                          ? selectedGoals.add(goal)
                          : selectedGoals.remove(goal);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: goalOtherController,
              decoration: const InputDecoration(hintText: 'Other goals...'),
            ),
            const SizedBox(height: 24),

            const Text(
              'What challenges are you facing?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 10,
              children: challenges.map((challenge) {
                return FilterChip(
                  label: Text(challenge),
                  selected: selectedChallenges.contains(challenge),
                  onSelected: (val) {
                    setState(() {
                      val
                          ? selectedChallenges.add(challenge)
                          : selectedChallenges.remove(challenge);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: challengeOtherController,
              decoration: const InputDecoration(
                hintText: 'Other challenges...',
              ),
            ),
            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: _onSubmit,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

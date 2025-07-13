import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mend_ai/providers/user_provider.dart';
import 'package:mend_ai/viewmodels/auth_viewmodel.dart';

class OnboardingGoalScreen extends ConsumerStatefulWidget {
  const OnboardingGoalScreen({super.key});

  @override
  ConsumerState<OnboardingGoalScreen> createState() =>
      _OnboardingGoalScreenState();
}

class _OnboardingGoalScreenState extends ConsumerState<OnboardingGoalScreen>
    with SingleTickerProviderStateMixin {
  final Set<String> selectedGoals = {};
  final TextEditingController otherGoalController = TextEditingController();

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  final List<String> goals = [
    "Communication",
    "Conflict resolution",
    "Intimacy",
    "Trust",
    "Shared decision-making",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    otherGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgGradient = LinearGradient(
      colors: [Color(0xffc2e9fb), Color(0xffa1c4fd), Color(0xffcfd9df)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: const BoxDecoration(gradient: bgGradient),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 24,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            "Let's personalize your experience",
                            style: GoogleFonts.laila(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            "What would you like to improve?",
                            style: GoogleFonts.laila(
                              fontSize: 18,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ListView(
                              children: [
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: goals.map((goal) {
                                    final isSelected = selectedGoals.contains(
                                      goal,
                                    );
                                    return FilterChip(
                                      label: Text(goal),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          selected
                                              ? selectedGoals.add(goal)
                                              : selectedGoals.remove(goal);
                                        });
                                      },
                                      selectedColor: Colors.blueAccent,
                                      backgroundColor: Colors.white,
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      checkmarkColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                if (selectedGoals.contains("Other"))
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: TextField(
                                      controller: otherGoalController,
                                      decoration: InputDecoration(
                                        hintText: "Other (please specify)",
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(
                                          0.85,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OnboardingChallengeScreen(
                                      selectedGoals: selectedGoals.toList(),
                                      otherGoal: otherGoalController.text
                                          .trim(),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.navigate_next,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Next",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
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
          ),
        ],
      ),
    );
  }
}

class OnboardingChallengeScreen extends ConsumerStatefulWidget {
  final List<String> selectedGoals;
  final String otherGoal;

  const OnboardingChallengeScreen({
    super.key,
    required this.selectedGoals,
    required this.otherGoal,
  });

  @override
  ConsumerState<OnboardingChallengeScreen> createState() =>
      _OnboardingChallengeScreenState();
}

class _OnboardingChallengeScreenState
    extends ConsumerState<OnboardingChallengeScreen>
    with SingleTickerProviderStateMixin {
  final Set<String> selectedChallenges = {};
  final TextEditingController otherChallengeController =
      TextEditingController();

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

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

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    otherChallengeController.dispose();
    super.dispose();
  }

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
      "goals": widget.selectedGoals,
      "otherGoal": widget.otherGoal,
      "challenges": selectedChallenges.toList(),
      "otherChallenge": otherChallengeController.text.trim(),
    };

    final success = await ref
        .read(authViewModelProvider) // ✅ FIXED HERE
        .submitOnboarding(payload);

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Submission failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: const BoxDecoration(
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
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 24,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            "What challenges are you facing?",
                            style: GoogleFonts.laila(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ListView(
                              children: [
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: challenges.map((challenge) {
                                    final isSelected = selectedChallenges
                                        .contains(challenge);
                                    return FilterChip(
                                      label: Text(challenge),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          selected
                                              ? selectedChallenges.add(
                                                  challenge,
                                                )
                                              : selectedChallenges.remove(
                                                  challenge,
                                                );
                                        });
                                      },
                                      selectedColor: Colors.blueAccent,
                                      backgroundColor: Colors.white,
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      checkmarkColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                if (selectedChallenges.contains("Other"))
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: TextField(
                                      controller: otherChallengeController,
                                      decoration: InputDecoration(
                                        hintText: "Other (please specify)",
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(
                                          0.85,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _submit,
                              icon: const Icon(Icons.flag, color: Colors.white),
                              label: Text(
                                "Finish",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
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
          ),
        ],
      ),
    );
  }
}

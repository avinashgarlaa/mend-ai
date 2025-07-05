// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/providers/mend_api_provider.dart';
import 'package:mend_ai/services/mend_api_service.dart';

// --- Model class to hold questionnaire data ---
class OnboardingData {
  final List<String> goals;
  final List<String> challenges;
  final String? name;
  final String? gender;
  final String? otherGoal;
  final String? otherChallenge;

  OnboardingData({
    this.goals = const [],
    this.challenges = const [],
    this.name,
    this.gender,
    this.otherGoal,
    this.otherChallenge,
  });

  OnboardingData copyWith({
    List<String>? goals,
    List<String>? challenges,
    String? name,
    String? gender,
    String? otherGoal,
    String? otherChallenge,
  }) {
    return OnboardingData(
      goals: goals ?? this.goals,
      challenges: challenges ?? this.challenges,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      otherGoal: otherGoal ?? this.otherGoal,
      otherChallenge: otherChallenge ?? this.otherChallenge,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "gender": gender,
      "goals": goals,
      "otherGoal": otherGoal,
      "challenges": challenges,
      "otherChallenge": otherChallenge,
    };
  }
}

// --- Riverpod StateNotifier ---
class OnboardingViewModel extends StateNotifier<OnboardingData> {
  final MendApiService api;

  OnboardingViewModel(this.api) : super(OnboardingData());

  Future<void> submitToBackend() async {
    await api.submitOnboarding(state.toJson());
  }

  void toggleGoal(String goal) {
    final updatedGoals = [...state.goals];
    if (updatedGoals.contains(goal)) {
      updatedGoals.remove(goal);
    } else {
      updatedGoals.add(goal);
    }
    state = state.copyWith(goals: updatedGoals);
  }

  void toggleChallenge(String challenge) {
    final updatedChallenges = [...state.challenges];
    if (updatedChallenges.contains(challenge)) {
      updatedChallenges.remove(challenge);
    } else {
      updatedChallenges.add(challenge);
    }
    state = state.copyWith(challenges: updatedChallenges);
  }

  void submitOnboardingData({
    required String name,
    required String gender,
    required String otherGoal,
    required String otherChallenge,
  }) async {
    state = state.copyWith(
      name: name,
      gender: gender,
      otherGoal: otherGoal.isNotEmpty ? otherGoal : null,
      otherChallenge: otherChallenge.isNotEmpty ? otherChallenge : null,
    );

    print("Submitting: ${state.toJson()}");

    try {
      await api.submitOnboarding(state.toJson());
      print("Onboarding submitted successfully");
    } catch (e) {
      print("Failed to submit onboarding: $e");
    }
  }
}

final onboardingViewModelProvider =
    StateNotifierProvider<OnboardingViewModel, OnboardingData>(
      (ref) => OnboardingViewModel(ref.watch(mendApiServiceProvider)),
    );

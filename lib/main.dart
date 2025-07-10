import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/viewmodels/auth_viewmodel.dart';
import 'package:mend_ai/views/auth/invite_partner_screen.dart';
import 'package:mend_ai/views/auth/login_screen.dart';
import 'package:mend_ai/views/auth/onboarding_screen.dart';
import 'package:mend_ai/views/auth/register_screen.dart';
import 'package:mend_ai/views/chat/chat_screen.dart';
import 'package:mend_ai/views/post_resolution/post_resolution_screen.dart';
import 'package:mend_ai/views/reflection/celebration_screen.dart';
import 'package:mend_ai/views/score/comm_score_screen.dart';
import 'package:mend_ai/views/session/session_screen.dart';
import 'package:mend_ai/views/home/home_screen.dart';
import 'package:mend_ai/views/insights/insights_screen.dart';
import 'package:mend_ai/views/reflection/reflection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MendApp()));
}

class MendApp extends ConsumerWidget {
  const MendApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Mend - Couples Therapy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Laila',
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xfff0f4ff),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      /// 🔐 Auto-login logic
      home: FutureBuilder<bool>(
        future: ref.read(authViewModelProvider).tryAutoLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data == true
              ? const HomeScreen()
              : const LoginScreen();
        },
      ),

      /// Named routes (used for navigation across screens)
      routes: {
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/onboarding': (context) => const OnboardingQuestionnaireScreen(),
        '/invite-partner': (context) => const InvitePartnerScreen(),
        '/start-session': (context) => const StartSessionScreen(),
        '/chat': (context) => const ChatScreen(),
        '/celebrate': (context) => const CelebrationScreen(),
        '/post-resolution': (context) => const PostResolutionScreen(),
        '/score': (context) => const ScoreScreen(),
      },

      /// Dynamic routes for screens needing params
      onGenerateRoute: (settings) {
        if (settings.name == '/insights') {
          return MaterialPageRoute(builder: (_) => InsightsScreen());
        }
        if (settings.name == '/reflection') {
          return MaterialPageRoute(builder: (_) => ReflectionScreen());
        }
        return null;
      },
    );
  }
}

import 'package:flutter/material.dart';
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

class MendApp extends StatelessWidget {
  const MendApp({super.key});

  @override
  Widget build(BuildContext context) {
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

      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
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
      onGenerateRoute: (settings) {
        // Insights screen with userId param
        if (settings.name == '/insights') {
          return MaterialPageRoute(builder: (_) => InsightsScreen());
        }

        // Reflection screen with userId and sessionId
        if (settings.name == '/reflection') {
          return MaterialPageRoute(builder: (_) => ReflectionScreen());
        }

        return null;
      },
    );
  }
}

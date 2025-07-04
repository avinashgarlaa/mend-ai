import 'package:flutter/material.dart';
import 'package:mend_ai/views/onboarding/onboarding_screen.dart';
import 'views/home/home_screen.dart';
import 'views/session/start_session_screen.dart';
import 'views/chat/moderate_chat_screen.dart';
import 'views/insights/insights_screen.dart';
import 'views/reflection/reflection_screen.dart';

class MendApp extends StatelessWidget {
  const MendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mend - Couples Therapy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/start-session': (context) => const StartSessionScreen(),
        '/moderate-chat': (context) => const ModerateChatScreen(),
        // Dynamic routes handled below
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/insights') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => InsightsScreen(userId: args['userId']),
          );
        } else if (settings.name == '/reflection') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ReflectionScreen(
              sessionId: args['sessionId'],
              userId: args['userId'],
            ),
          );
        }
        return null;
      },
    );
  }
}

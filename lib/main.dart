import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Screens & ViewModels
import 'package:mend_ai/viewmodels/auth_viewmodel.dart';
import 'package:mend_ai/views/auth/login_screen.dart';
import 'package:mend_ai/views/auth/register_screen.dart';
import 'package:mend_ai/views/auth/invite_partner_screen.dart';
import 'package:mend_ai/views/auth/onboarding_screen.dart';
import 'package:mend_ai/views/chat/chat_screen.dart';
import 'package:mend_ai/views/home/home_screen.dart';
import 'package:mend_ai/views/session/session_screen.dart';
import 'package:mend_ai/views/post_resolution/post_resolution_screen.dart';
import 'package:mend_ai/views/reflection/celebration_screen.dart';
import 'package:mend_ai/views/score/comm_score_screen.dart';
import 'package:mend_ai/views/reflection/reflection_screen.dart';
import 'package:mend_ai/views/insights/insights_screen.dart';

void main() {
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
        useMaterial3: true,
        fontFamily: 'Laila',
        scaffoldBackgroundColor: const Color(0xfff0f4ff),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        textTheme: GoogleFonts.varelaRoundTextTheme(),
      ),

      home: FutureBuilder<bool>(
        future: ref.read(authViewModelProvider).tryAutoLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SplashScreen();
          }

          final loggedIn = snapshot.data ?? false;
          return loggedIn ? const HomeScreen() : const LoginScreen();
        },
      ),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingGoalScreen(),
        '/invite-partner': (context) => const InvitePartnerScreen(),
        '/start-session': (context) => const StartSessionScreen(),
        '/chat': (context) => const ChatScreen(),
        '/celebrate': (context) => const CelebrationScreen(),
        '/post-resolution': (context) => const PostResolutionScreen(),
        '/score': (context) => const ScoreScreen(),
      },

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/insights':
            return MaterialPageRoute(builder: (_) => const InsightsScreen());
          case '/reflection':
            return MaterialPageRoute(builder: (_) => const ReflectionScreen());
          default:
            return null;
        }
      },
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 7000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    );

    _logoController.forward();

    // Optional: Navigate automatically after delay (if needed)
    // Future.delayed(const Duration(seconds: 3), () {
    //   Navigator.pushReplacementNamed(context, '/home');
    // });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f4ff),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 30,
                        color: Colors.deepPurple.withOpacity(0.15),
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 72,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Mend",
                style: GoogleFonts.laila(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Healing together, one step at a time",
                style: GoogleFonts.varelaRound(
                  fontSize: 16,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

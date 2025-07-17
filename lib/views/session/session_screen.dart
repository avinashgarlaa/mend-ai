import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mend_ai/models/session_model.dart';
import 'package:mend_ai/models/user_model.dart';
import 'package:mend_ai/providers/user_provider.dart';
import 'package:mend_ai/viewmodels/auth_viewmodel.dart';
import 'package:mend_ai/viewmodels/session_viewmodel.dart';

class StartSessionScreen extends ConsumerStatefulWidget {
  const StartSessionScreen({super.key});

  @override
  ConsumerState<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends ConsumerState<StartSessionScreen> {
  final TextEditingController contextController = TextEditingController();
  bool isLoading = false;
  bool isFetching = true;

  User? partner;
  Session? existingSession;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  Future<void> _initData() async {
    final user = ref.read(userProvider);
    if (user == null || user.partnerId.isEmpty) {
      setState(() => isFetching = false);
      return;
    }
    final authVM = ref.read(authViewModelProvider);
    final sessionVM = ref.read(sessionViewModelProvider.notifier);
    try {
      final partnerRes = await authVM.getPartnerDetails(user.partnerId);
      final sessionRes = await sessionVM.getActiveSession(user.id);

      setState(() {
        partner = partnerRes;
        existingSession = sessionRes;
      });
    } catch (_) {
      setState(() {
        partner = null;
        existingSession = null;
      });
    } finally {
      setState(() => isFetching = false);
    }
  }

  Future<void> _startSession() async {
    final user = ref.read(userProvider);
    if (user == null || user.partnerId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Partner not linked")));
      return;
    }

    setState(() => isLoading = true);

    final session = await ref
        .read(sessionViewModelProvider.notifier)
        .startSession(
          partnerA: user.id,
          partnerB: user.partnerId,
          initialContext: contextController.text.trim(),
        );

    setState(() => isLoading = false);

    if (session != null) {
      ref.read(userProvider.notifier).updateSessionId(session.id);
      Navigator.pushReplacementNamed(context, '/call');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to start session")));
    }
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassHeader(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black54,
                ),
                onPressed: () => Navigator.pushNamed(context, "/home"),
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.montserrat(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "Start Your ",
                      style: GoogleFonts.aBeeZee(color: Colors.black87),
                    ),
                    TextSpan(
                      text: "Session",
                      style: GoogleFonts.aBeeZee(color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSessionCard(List<Widget> content) {
    return _buildGlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content,
        ),
      ),
    );
  }

  Widget _buildSessionContextInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 10),
            Text(
              "Session Context (optional)",
              style: GoogleFonts.aBeeZee(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: contextController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "What would you like to discuss?",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionButton(User user) {
    final isOngoing = existingSession != null;

    return ElevatedButton.icon(
      onPressed: isLoading
          ? null
          : () {
              if (isOngoing) {
                ref
                    .read(userProvider.notifier)
                    .updateSessionId(existingSession!.id);
                Navigator.pushReplacementNamed(context, '/call');
              } else {
                _startSession();
              }
            },
      icon: Icon(isOngoing ? Icons.login : Icons.chat, color: Colors.white),
      label: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              isOngoing ? "Join Ongoing Session" : "Start Voice Session",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
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
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildGlassHeader(context, ref),
                  const SizedBox(height: 20),
                  if (user == null)
                    const Expanded(child: Center(child: Text("User not found")))
                  else if (isFetching)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 40),
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 10),
                              Text(
                                existingSession != null
                                    ? "Join Your Ongoing Session"
                                    : "Start a New Session",
                                style: GoogleFonts.aBeeZee(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildSessionCard([
                            _buildRow("You        ", user.name.toUpperCase()),
                            _buildRow("Gender  ", user.gender),
                            _buildRow("Email     ", user.email),
                          ]),
                          const SizedBox(height: 16),
                          if (partner != null)
                            _buildSessionCard([
                              Text(
                                "Partner Details",
                                style: GoogleFonts.aBeeZee(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildRow("Name     ", partner!.name),
                              _buildRow("Gender  ", partner!.gender),
                              _buildRow("Email     ", partner!.email),
                            ])
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                "  Please link your partner first to start a session.",
                                style: GoogleFonts.aBeeZee(
                                  fontSize: 14,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          _buildSessionContextInput(),
                          const SizedBox(height: 30),
                          _buildSessionButton(user),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

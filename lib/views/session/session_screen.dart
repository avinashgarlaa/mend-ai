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
    if (user == null || user.partnerId.isEmpty) return;

    final authVM = ref.read(authViewModelProvider);
    final sessionVM = ref.read(sessionViewModelProvider.notifier);

    setState(() => isFetching = true);

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
      Navigator.pushReplacementNamed(context, '/chat');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to start session")));
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff8e2de2), Color(0xff4a00e0)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            "Session Setup",
            style: GoogleFonts.laila(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _buildUserDetailsCard(User user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow("You", user.name),
            const SizedBox(height: 8),
            _buildRow("Email", user.email),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerCard(User partner) {
    return Card(
      color: Colors.deepPurple.shade50,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Partner Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            _buildRow("Name", partner.name),
            const SizedBox(height: 8),
            _buildRow("Email", partner.email),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionContextInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Session Context (optional)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: contextController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "What would you like to discuss?",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionButton(User user) {
    final isOngoing = existingSession != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading
            ? null
            : () {
                if (isOngoing) {
                  ref
                      .read(userProvider.notifier)
                      .updateSessionId(existingSession!.id);
                  Navigator.pushReplacementNamed(context, '/chat');
                } else {
                  _startSession();
                }
              },
        icon: Icon(isOngoing ? Icons.login : Icons.mic, color: Colors.white),
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xfff0f4ff),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (user == null)
              const Expanded(child: Center(child: Text("User not found")))
            else if (isFetching)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  children: [
                    Text(
                      existingSession != null
                          ? "Join Your Ongoing Session"
                          : "Start a New Session",
                      style: GoogleFonts.laila(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildUserDetailsCard(user),
                    const SizedBox(height: 16),
                    if (partner != null) _buildPartnerCard(partner!),
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
    );
  }
}

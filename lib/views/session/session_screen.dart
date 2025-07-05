// lib/views/start_session_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/models/session.dart';
import 'package:mend_ai/providers/user_provider.dart';
import 'package:mend_ai/viewmodels/session_viewmodel.dart';

class StartSessionScreen extends ConsumerStatefulWidget {
  const StartSessionScreen({super.key});

  @override
  ConsumerState<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends ConsumerState<StartSessionScreen> {
  final TextEditingController contextController = TextEditingController();

  void _startSession() async {
    final user = ref.read(userProvider);
    final contextText = contextController.text.trim();

    if (user == null || user.partnerId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Partner not linked")));
      return;
    }

    final success = await ref
        .read(sessionViewModelProvider.notifier)
        .startSession(
          partnerA: user.id,
          partnerB: user.partnerId,
          initialContext: contextText,
        );

    if (success != null) {
      final Session session = success;
      ref.read(userProvider.notifier).updateSessionId(session.id);

      Navigator.pushReplacementNamed(context, '/chat');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to start session")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Start a New Session")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: user == null
            ? const Center(child: Text("User not found"))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "You:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(user.name),
                  const SizedBox(height: 12),
                  const Text(
                    "Partner ID:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(user.partnerId),
                  const SizedBox(height: 24),
                  const Text(
                    "Session Context (Optional):",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: contextController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText:
                          "Describe the topic you'd like to discuss today...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _startSession,
                    icon: const Icon(Icons.mic),
                    label: const Text("Start Voice Session"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/providers/mend_provider.dart';
import '../../providers/user_provider.dart';

class PostResolutionScreen extends ConsumerStatefulWidget {
  const PostResolutionScreen({super.key});

  @override
  ConsumerState<PostResolutionScreen> createState() =>
      _PostResolutionScreenState();
}

class _PostResolutionScreenState extends ConsumerState<PostResolutionScreen> {
  final gratitudeController = TextEditingController();
  final reflectionController = TextEditingController();
  final bondingController = TextEditingController();

  void _submit() async {
    final user = ref.read(userProvider);
    final api = ref.read(mendServiceProvider);

    if (user == null) return;

    final payload = {
      "userId": user.id,
      "sessionId": user.currentSessionId ?? "",
      "gratitude": gratitudeController.text,
      "reflection": reflectionController.text,
      "bondingActivity": bondingController.text,
    };

    await api.submitPostResolution(payload);

    Navigator.pushNamed(context, '/reflection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post-Resolution")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: gratitudeController,
              decoration: const InputDecoration(
                labelText: "Gratitude for partner",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reflectionController,
              decoration: const InputDecoration(
                labelText: "What did you learn?",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bondingController,
              decoration: const InputDecoration(
                labelText: "Bonding activity suggestion",
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("Continue to Reflection"),
            ),
          ],
        ),
      ),
    );
  }
}

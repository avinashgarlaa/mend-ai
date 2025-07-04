import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/viewmodels/session_viewmodel.dart';

class StartSessionScreen extends ConsumerStatefulWidget {
  const StartSessionScreen({super.key});

  @override
  ConsumerState<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends ConsumerState<StartSessionScreen> {
  final _partnerAController = TextEditingController();
  final _partnerBController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionViewModelProvider);
    final sessionVM = ref.read(sessionViewModelProvider.notifier);

    ref.listen(sessionViewModelProvider, (previous, next) {
      next.whenData((session) {
        if (session != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session started successfully!')),
          );
          // Navigate to chat or other next screen as needed
        }
      });

      next.when(
        data: (_) {},
        loading: () {},
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error starting session: $error')),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Start Therapy Session')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _partnerAController,
              decoration: const InputDecoration(labelText: 'Partner A ID'),
            ),
            TextField(
              controller: _partnerBController,
              decoration: const InputDecoration(labelText: 'Partner B ID'),
            ),
            const SizedBox(height: 20),
            sessionState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      final partnerA = _partnerAController.text.trim();
                      final partnerB = _partnerBController.text.trim();

                      if (partnerA.isEmpty || partnerB.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill both partner IDs'),
                          ),
                        );
                        return;
                      }

                      sessionVM.startSession({
                        'partnerA': partnerA,
                        'partnerB': partnerB,
                      });
                    },
                    child: const Text('Start Session'),
                  ),
          ],
        ),
      ),
    );
  }
}

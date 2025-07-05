import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/viewmodels/invite_viewmodel.dart';

class InvitePartnerScreen extends ConsumerWidget {
  const InvitePartnerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(inviteViewModelProvider.notifier);
    final state = ref.watch(inviteViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Invite Your Partner")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Invite your partner using their Partner ID.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: "Partner ID"),
              onChanged: vm.setPartnerId,
            ),
            const SizedBox(height: 20),
            state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await vm.sendInvite();
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Invitation sent successfully!"),
                            ),
                          );
                          Navigator.pushNamed(context, '/start-session');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Failed to send invite"),
                            ),
                          );
                        }
                      },
                      child: const Text("Send Invite"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

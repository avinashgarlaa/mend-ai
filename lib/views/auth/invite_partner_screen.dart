// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class InvitePartnerScreen extends StatelessWidget {
  const InvitePartnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This would normally be pulled from Riverpod or passed as an argument
    final userId = 'abc123'; // example invite code (replace with real user ID)
    final inviteLink = 'https://mend.app/invite/$userId';
    final message =
        "Hi, I just joined Mend — an AI-powered app to help us grow closer and communicate better. 💙\n\nJoin me here: $inviteLink";

    return Scaffold(
      appBar: AppBar(title: const Text('Invite Your Partner')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mend works best when you're both here.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Send your partner an invite to join your relationship space.",
            ),
            const SizedBox(height: 24),

            // Invite code display
            Row(
              children: [
                Expanded(
                  child: Text(
                    inviteLink,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: inviteLink));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invite link copied!")),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () => Share.share(message),
              icon: const Icon(Icons.share),
              label: const Text("Share Invite"),
            ),

            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // After inviting, continue to session start
                  Navigator.pushReplacementNamed(context, '/start-session');
                },
                child: const Text("Skip & Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

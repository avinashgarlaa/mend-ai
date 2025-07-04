import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mend - Home')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/start-session');
              },
              child: const Text('Start New Session'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to insights screen, example with dummy userId
                Navigator.pushNamed(
                  context,
                  '/insights',
                  arguments: {'userId': 'user123'},
                );
              },
              child: const Text('View Communication Insights'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to moderated chat screen
                Navigator.pushNamed(context, '/moderate-chat');
              },
              child: const Text('Go to Moderated Chat'),
            ),
            const SizedBox(height: 16),
            // Add more buttons/links as needed
          ],
        ),
      ),
    );
  }
}

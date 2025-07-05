// lib/views/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/providers/user_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mend Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // You can implement logout functionality here
              ref.read(userProvider.notifier).clearUser();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text("User not found"))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  _buildProfileCard(user),
                  const SizedBox(height: 24),
                  const Text(
                    "Explore",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureTile(
                    context,
                    title: "Start New Session",
                    subtitle: "Have a guided conversation",
                    icon: Icons.mic,
                    route: "/start-session",
                  ),
                  _buildFeatureTile(
                    context,
                    title: "Post-Session Reflection",
                    subtitle: "Reflect and grow together",
                    icon: Icons.self_improvement,
                    route: "/reflection",
                  ),
                  _buildFeatureTile(
                    context,
                    title: "Your Insights",
                    subtitle: "View your emotional journey",
                    icon: Icons.insights,
                    route: "/insights",
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard(user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.deepPurple,
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 28, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Partner ID: ${user.id}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            if (user.partnerId != null && user.partnerId.isNotEmpty)
              Column(
                children: [
                  const Divider(),
                  const Text(
                    "Partner Linked",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "Partner ID: ${user.partnerId}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple.shade100,
        child: Icon(icon, color: Colors.deepPurple),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}

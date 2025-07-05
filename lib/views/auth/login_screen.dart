// lib/views/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/viewmodels/auth_viewmodel.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Welcome Back")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Login with your Partner ID",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Partner ID",
                prefixIcon: Icon(Icons.vpn_key),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final id = controller.text.trim();
                  final success = await ref
                      .read(authViewModelProvider)
                      .login(id);
                  if (success) {
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacementNamed(context, '/invite-partner');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Login failed")),
                    );
                  }
                },
                child: const Text("Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

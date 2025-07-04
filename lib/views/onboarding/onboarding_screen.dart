import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/viewmodels/user_viewmodel.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isRegistering = true;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userViewModelProvider);
    final userVM = ref.read(userViewModelProvider.notifier);

    ref.listen(userViewModelProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Welcome, ${user.name}!')));
          Navigator.pushReplacementNamed(context, '/start-session');
        }
      });

      next.when(
        data: (_) {},
        loading: () {},
        error: (error, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $error')));
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Mend')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _isRegistering ? 'Register' : 'Login',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            if (_isRegistering)
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            userState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      final email = _emailController.text.trim();
                      final name = _nameController.text.trim();

                      if (email.isEmpty || (_isRegistering && name.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all fields'),
                          ),
                        );
                        return;
                      }

                      if (_isRegistering) {
                        userVM.registerUser({'name': name, 'email': email});
                      } else {
                        // For demo, login just checks user exists — you can expand this
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Login not implemented yet'),
                          ),
                        );
                      }
                    },
                    child: Text(_isRegistering ? 'Register' : 'Login'),
                  ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isRegistering = !_isRegistering;
                });
              },
              child: Text(
                _isRegistering
                    ? 'Already have an account? Login'
                    : 'Create an account',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

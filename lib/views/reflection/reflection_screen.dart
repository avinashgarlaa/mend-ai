import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/viewmodels/reflection_viewmodel.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String userId;

  const ReflectionScreen({
    super.key,
    required this.sessionId,
    required this.userId,
  });

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final reflectionState = ref.watch(reflectionViewModelProvider);
    final reflectionVM = ref.read(reflectionViewModelProvider.notifier);

    ref.listen(reflectionViewModelProvider, (previous, next) {
      next.whenData((reflection) {
        if (reflection != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Reflection saved')));
          Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Post-Session Reflection')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Reflection'),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            reflectionState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      final content = _contentController.text.trim();
                      if (content.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter reflection'),
                          ),
                        );
                        return;
                      }

                      reflectionVM.saveReflection({
                        'sessionId': widget.sessionId,
                        'userId': widget.userId,
                        'content': content,
                      });
                    },
                    child: const Text('Submit'),
                  ),
          ],
        ),
      ),
    );
  }
}

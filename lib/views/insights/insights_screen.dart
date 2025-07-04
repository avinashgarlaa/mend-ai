import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/models/reflection.dart';
import 'package:mend_ai/models/session.dart';
import 'package:mend_ai/viewmodels/insights_viewmodel.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  final String userId;
  const InsightsScreen({super.key, required this.userId});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(insightsViewModelProvider.notifier)
          .fetchInsights(widget.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final insightsState = ref.watch(insightsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Communication Insights')),
      body: insightsState.when(
        data: (data) {
          final sessionsJson = data['sessions'] as List<dynamic>? ?? [];
          final reflectionsJson = data['reflections'] as List<dynamic>? ?? [];

          final sessions = sessionsJson
              .map((e) => Session.fromJson(e))
              .toList();
          final reflections = reflectionsJson
              .map((e) => Reflection.fromJson(e))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Sessions:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              ...sessions.map(
                (s) => ListTile(
                  title: Text('Session ID: ${s.id}'),
                  subtitle: Text('Partners: ${s.partnerA} & ${s.partnerB}'),
                  trailing: s.resolved
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.pending, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Reflections:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              ...reflections.map(
                (r) => ListTile(
                  title: Text('Reflection by User: ${r.userId}'),
                  subtitle: Text(r.content),
                  trailing: Text(
                    DateTime.fromMillisecondsSinceEpoch(
                      r.timestamp * 1000,
                    ).toLocal().toString(),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

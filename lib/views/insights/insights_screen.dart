import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/providers/mend_provider.dart';
import '../../providers/user_provider.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  bool isLoading = true;
  List sessions = [];
  List reflections = [];

  Future<void> loadInsights() async {
    final user = ref.read(userProvider);
    final api = ref.read(mendServiceProvider);

    if (user == null) return;

    try {
      final res = await api.getInsights(user.id);
      sessions = res.data['sessions'];
      reflections = res.data['reflections'];
    } catch (e) {
      print("Error loading insights: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    loadInsights();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Insights")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "🗣️ Past Sessions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...sessions.map(
                  (s) => Card(
                    child: ListTile(
                      title: Text(
                        "Session with ${s['partnerA']} & ${s['partnerB']}",
                      ),
                      subtitle: Text(
                        "Resolved: ${s['resolved'] ? 'Yes' : 'No'}",
                      ),
                      trailing: Text(
                        DateTime.fromMillisecondsSinceEpoch(
                          s['createdAt'] * 1000,
                        ).toLocal().toString().split('.')[0],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "🧘 Your Reflections",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...reflections.map(
                  (r) => Card(
                    child: ListTile(
                      title: Text(r['text'] ?? "No text"),
                      subtitle: Text("Session ID: ${r['sessionId']}"),
                      trailing: Text(
                        DateTime.fromMillisecondsSinceEpoch(
                          r['timestamp'] * 1000,
                        ).toLocal().toString().split('.')[0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

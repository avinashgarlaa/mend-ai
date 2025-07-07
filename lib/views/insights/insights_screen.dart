import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mend_ai/providers/mend_provider.dart';
import 'package:mend_ai/providers/user_provider.dart';
import 'package:mend_ai/views/insights/insights_chart.dart'; // Chart widget
import 'package:intl/intl.dart';

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

  String formatDate(int timestamp) {
    return DateFormat(
      'MMM d, yyyy – hh:mm a',
    ).format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Your Insights")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "📊 Communication Score Trends",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ScoreChart(scores: _extractScores(user?.id ?? "")),
                const Divider(height: 40),

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
                      trailing: Text(formatDate(s['createdAt'])),
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
                      trailing: Text(formatDate(r['timestamp'])),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  List<Map<String, dynamic>> _extractScores(String userId) {
    return sessions.map((s) {
      final score = s['partnerA'] == userId ? s['scoreA'] : s['scoreB'];
      return {
        'score': [
          score['empathy'] ?? 0,
          score['listening'] ?? 0,
          score['clarity'] ?? 0,
          score['respect'] ?? 0,
          score['responsiveness'] ?? 0,
          score['openMindedness'] ?? 0,
        ],
      };
    }).toList();
  }
}

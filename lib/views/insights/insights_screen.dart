import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mend_ai/providers/mend_provider.dart';
import 'package:mend_ai/providers/user_provider.dart';
import 'package:mend_ai/views/insights/insights_chart.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  bool isLoading = true;
  List sessions = [];
  List reflections = [];

  @override
  void initState() {
    super.initState();
    loadInsights();
  }

  Future<void> loadInsights() async {
    final user = ref.read(userProvider);
    final api = ref.read(mendServiceProvider);

    if (user == null) return;

    try {
      final res = await api.getInsights(user.id);
      sessions = res.data['sessions'];
      reflections = res.data['reflections'];
    } catch (e) {
      print("⚠️ Error loading insights: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  String formatDate(int timestamp) {
    return DateFormat(
      'MMM d, yyyy – hh:mm a',
    ).format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));
  }

  List<Map<String, dynamic>> _extractScores(String userId) {
    return sessions.map((s) {
      final score = s['partnerA'] == userId ? s['scoreA'] : s['scoreB'];
      return {
        'empathy': score?['empathy'] ?? 0,
        'listening': score?['listening'] ?? 0,
        'clarity': score?['clarity'] ?? 0,
        'respect': score?['respect'] ?? 0,
        'responsiveness': score?['responsiveness'] ?? 0,
        'openMindedness': score?['openMindedness'] ?? 0,
      };
    }).toList();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 16, right: 16),
      child: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, String userId) {
    final otherId = session['partnerA'] == userId
        ? session['partnerB']
        : session['partnerA'];
    final resolved = session['resolved'] == true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          "Session with $otherId",
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "Resolved: ${resolved ? 'Yes' : 'No'}",
          style: GoogleFonts.lato(),
        ),
        trailing: Text(
          formatDate(session['createdAt']),
          style: GoogleFonts.lato(fontSize: 11, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildReflectionCard(dynamic reflection) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          reflection['text'] ?? "No reflection provided.",
          style: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.w500),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "Session ID: ${reflection['sessionId']}",
          style: GoogleFonts.lato(fontSize: 13),
        ),
        trailing: Text(
          formatDate(reflection['timestamp']),
          style: GoogleFonts.lato(fontSize: 11, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff8e2de2), Color(0xff4a00e0)],
        ),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            Text(
              "Insights",
              style: GoogleFonts.laila(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xfff0f4ff),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadInsights,
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Communication Trends"),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: const Offset(1, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: ScoreChart(
                                scores: _extractScores(user?.id ?? ""),
                              ),
                            ),

                            _buildSectionTitle("Past Sessions"),
                            if (sessions.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  "No sessions yet.",
                                  style: GoogleFonts.lato(),
                                ),
                              )
                            else
                              ...sessions.map(
                                (s) => _buildSessionCard(s, user?.id ?? ""),
                              ),

                            _buildSectionTitle("Your Reflections"),
                            if (reflections.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  "No reflections yet.",
                                  style: GoogleFonts.lato(),
                                ),
                              )
                            else
                              ...reflections.map(_buildReflectionCard),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

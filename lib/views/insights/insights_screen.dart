import 'dart:ui';
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
      debugPrint("⚠️ Error loading insights: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  String formatDate(int timestamp) {
    return DateFormat(
      'MMM d, yyyy • h:mm a',
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

  Widget _glassCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(padding: const EdgeInsets.all(20), child: child),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 05, 20, 05),
      child: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black.withOpacity(0.95),
        ),
      ),
    );
  }

  Widget _buildSessionCard(int index, Map<String, dynamic> session) {
    final createdAt = session['createdAt'] ?? 0;
    final resolved = session['resolved'] == true;

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people_alt_rounded,
                color: Colors.black.withOpacity(0.75),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Session ${index + 1}",
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.75),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: resolved
                      ? Colors.black.withOpacity(0.25)
                      : Colors.pinkAccent.withOpacity(0.2),
                ),
                child: Text(
                  resolved ? "Resolved" : "Unresolved",
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: resolved ? Colors.white : Colors.pinkAccent.shade100,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatDate(createdAt),
            style: GoogleFonts.lato(
              fontSize: 13,
              color: Colors.black38.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionCard(int index, dynamic reflection) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "“${reflection['text'] ?? "No reflection provided."}”",
            style: GoogleFonts.lato(
              fontSize: 14.5,
              fontStyle: FontStyle.italic,
              color: Colors.black54.withOpacity(0.96),
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              formatDate(reflection['timestamp']),
              style: GoogleFonts.lato(
                fontSize: 12,
                color: Colors.black38.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassHeader(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.montserrat(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "Insights ",
                      style: GoogleFonts.aBeeZee(color: Colors.black87),
                    ),
                    TextSpan(
                      text: "Reflection",
                      style: GoogleFonts.aBeeZee(color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildHeader() {
  //   return SafeArea(
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  //       child: Row(
  //         children: [
  //           IconButton(
  //             icon: const Icon(
  //               Icons.arrow_back_ios_new_rounded,
  //               color: Colors.white,
  //               size: 20,
  //             ),
  //             onPressed: () => Navigator.pop(context),
  //           ),
  //           const SizedBox(width: 8),
  //           Text(
  //             "Insights",
  //             style: GoogleFonts.lato(
  //               fontSize: 26,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.white.withOpacity(0.97),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffc2e9fb), Color(0xffa1c4fd), Color(0xffcfd9df)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : RefreshIndicator(
                color: Colors.white,
                onRefresh: loadInsights,
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10,
                        ),
                        child: _buildGlassHeader(context, ref),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _sectionTitle("Communication Trends"),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: ScoreChart(
                                  scores: _extractScores(user?.id ?? ""),
                                ),
                              ),
                              _sectionTitle("Past Sessions"),
                              if (sessions.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                  ),
                                  child: Text(
                                    "No sessions yet.",
                                    style: GoogleFonts.lato(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                )
                              else
                                ...List.generate(
                                  sessions.length,
                                  (i) => _buildSessionCard(i, sessions[i]),
                                ),
                              _sectionTitle("Your Reflections"),
                              if (reflections.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                  ),
                                  child: Text(
                                    "No reflections yet.",
                                    style: GoogleFonts.lato(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                )
                              else
                                ...List.generate(
                                  reflections.length,
                                  (i) =>
                                      _buildReflectionCard(i, reflections[i]),
                                ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

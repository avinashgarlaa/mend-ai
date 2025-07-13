import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mend_ai/models/user_model.dart';
import 'package:mend_ai/providers/user_provider.dart';
import 'package:mend_ai/viewmodels/auth_viewmodel.dart';

class InvitePartnerScreen extends ConsumerStatefulWidget {
  const InvitePartnerScreen({super.key});

  @override
  ConsumerState<InvitePartnerScreen> createState() =>
      _InvitePartnerScreenState();
}

class _InvitePartnerScreenState extends ConsumerState<InvitePartnerScreen> {
  final TextEditingController partnerIdController = TextEditingController();
  User? partnerDetails;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPartnerDetails();
  }

  void _fetchPartnerDetails() async {
    final user = ref.read(userProvider);
    if (user != null && user.partnerId.isNotEmpty) {
      setState(() => isLoading = true);
      final partner = await ref
          .read(authViewModelProvider)
          .getPartnerDetails(user.partnerId);
      setState(() {
        partnerDetails = partner;
        isLoading = false;
      });
    }
  }

  void _submitInvite() async {
    final user = ref.read(userProvider);
    final partnerId = partnerIdController.text.trim();

    if (user == null || partnerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your partner's ID")),
      );
      return;
    }

    setState(() => isLoading = true);
    final success = await ref
        .read(authViewModelProvider)
        .linkPartner(user.id, partnerId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎉 Partner linked successfully!")),
      );
      _fetchPartnerDetails();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Failed to link partner")));
    }
    setState(() => isLoading = false);
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
                ),
                onPressed: () => Navigator.pushNamed(context, "/home"),
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  children: [
                    TextSpan(
                      text: "Invite ",
                      style: GoogleFonts.aBeeZee(color: Colors.black87),
                    ),
                    TextSpan(
                      text: "Partner",
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

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildInviteCard(User? user) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your ID", style: GoogleFonts.aBeeZee(fontSize: 13)),
          // const SizedBox(height: 6),
          Row(
            children: [
              SelectableText(
                user?.id ?? "N/A",
                style: GoogleFonts.aBeeZee(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),

              IconButton(
                icon: const Icon(Icons.copy, color: Colors.blueAccent),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: user?.id ?? ""));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Partner ID copied")),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text("Enter partner ID", style: GoogleFonts.aBeeZee(fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: partnerIdController,
            decoration: InputDecoration(
              hintText: "e.g. partner-uuid",
              labelText: "Partner ID",
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitInvite,
              icon: const Icon(Icons.favorite_outline),
              label: Text(
                "Link Partner",
                style: GoogleFonts.laila(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(User partner) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🎉 Partner Linked!",
            style: GoogleFonts.aBeeZee(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.blueAccent),
              const SizedBox(width: 10),
              Text("Name: ${partner.name}", style: GoogleFonts.aBeeZee()),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.email, color: Colors.blueAccent),
              const SizedBox(width: 10),
              Text("Email: ${partner.email}", style: GoogleFonts.aBeeZee()),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xfff0f4ff),
      body: Stack(
        children: [
          const _AnimatedGradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildGlassHeader(context, ref),
                  const SizedBox(height: 24),
                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.deepPurple,
                            ),
                          )
                        : ListView(
                            physics: NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 30),
                            children: [
                              // Text(
                              //   "Partner Connection",
                              //   style: GoogleFonts.laila(
                              //     fontSize: 22,
                              //     fontWeight: FontWeight.bold,
                              //     color: Colors.deepPurple,
                              //   ),
                              // ),
                              const SizedBox(height: 05),
                              partnerDetails != null
                                  ? _buildPartnerCard(partnerDetails!)
                                  : _buildInviteCard(user),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedGradientBackground extends StatelessWidget {
  const _AnimatedGradientBackground();

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffc2e9fb), Color(0xffa1c4fd), Color(0xffcfd9df)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

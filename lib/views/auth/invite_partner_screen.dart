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
        const SnackBar(content: Text("🎉 Invitation sent and partner linked!")),
      );
      _fetchPartnerDetails(); // Refresh details
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to link partner")));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xfff0f4ff),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepPurple,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      children: [
                        Text(
                          "Partner Connection",
                          style: GoogleFonts.laila(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 12),
                        partnerDetails != null
                            ? _buildPartnerCard(partnerDetails!)
                            : _buildInviteCard(user),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteCard(User? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your ID:", style: GoogleFonts.varelaRound(fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  user?.id ?? "N/A",
                  style: GoogleFonts.varelaRound(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.deepPurple),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: user?.id ?? ""));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Partner ID copied")),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Enter your partner’s ID:",
            style: GoogleFonts.varelaRound(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: partnerIdController,
            decoration: const InputDecoration(
              labelText: "Partner's ID",
              prefixIcon: Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitInvite,
              icon: const Icon(Icons.favorite_outline),
              label: Text(
                "Link Partner",
                style: GoogleFonts.laila(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffe0c3fc), Color(0xff8ec5fc)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🎉 Partner Linked!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Text(
                "Name: ${partner.name}",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.mail_outline, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Text(
                "Email: ${partner.email}",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff8e2de2), Color(0xff4a00e0)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            "Partner Invite",
            style: GoogleFonts.laila(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

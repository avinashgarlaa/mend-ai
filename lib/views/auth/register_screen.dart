// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mend_ai/viewmodels/auth_viewmodel.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late final AnimationController _titleController;
  late final Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();

  String gender = 'Male';
  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeIn,
    );
    _titleController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final userData = {
      "name": nameController.text.trim(),
      "gender": gender,
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
    };

    print(userData);

    final success = await ref
        .read(authViewModelProvider)
        .registerUser(userData, passwordController.text.trim().toString());

    setState(() => isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Registration failed")));
    }
  }

  // Future<void> _handleGoogleSignIn() async {
  //   setState(() => isLoading = true);
  //   final googleUser = await GoogleSignIn(scopes: ['email']).signIn();

  //   if (googleUser == null) {
  //     setState(() => isLoading = false);
  //     return;
  //   }

  //   final success = await ref
  //       .read(authViewModelProvider)
  //       .loginWithGoogle(googleUser);

  //   setState(() => isLoading = false);

  //   if (success) {
  //     Navigator.pushReplacementNamed(context, '/onboarding');
  //   } else {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Google Sign-In failed.")));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blueAccent;

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // allows scroll view to react to keyboard
      body: Stack(
        children: [
          // Background gradient
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xffc2e9fb),
                  Color(0xffa1c4fd),
                  Color(0xffcfd9df),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Main content
          Center(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 500,
                        maxHeight: 800,
                      ),
                      child: IntrinsicHeight(
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                              child: Container(
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 24,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FadeTransition(
                                        opacity: _fadeAnimation,
                                        child: RichText(
                                          textAlign: TextAlign.start,
                                          text: TextSpan(
                                            style: GoogleFonts.montserrat(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            children: [
                                              const TextSpan(
                                                text: "Create your ",
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              TextSpan(
                                                text: "Account",
                                                style: TextStyle(
                                                  color: themeColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // _buildLabel("Name"),
                                      const SizedBox(height: 8),
                                      _buildTextField(
                                        controller: nameController,
                                        hint: "Enter your full name",
                                        icon: Icons.person_outline,
                                        validator: (value) => value!.isEmpty
                                            ? "Name required"
                                            : null,
                                      ),

                                      const SizedBox(height: 16),
                                      // _buildLabel("Email"),
                                      const SizedBox(height: 8),
                                      _buildTextField(
                                        controller: emailController,
                                        hint: "Enter your email",
                                        icon: Icons.mail_outline,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (value) =>
                                            value!.contains('@')
                                            ? null
                                            : "Enter a valid email",
                                      ),

                                      const SizedBox(height: 16),
                                      // _buildLabel("Password"),
                                      const SizedBox(height: 8),
                                      _buildTextField(
                                        controller: passwordController,
                                        hint: "Create a password",
                                        icon: Icons.lock_outline,
                                        obscure: obscurePassword,
                                        validator: (value) => value!.length < 6
                                            ? "Minimum 6 characters"
                                            : null,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            obscurePassword
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Colors.grey.shade700,
                                          ),
                                          onPressed: () => setState(
                                            () => obscurePassword =
                                                !obscurePassword,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 16),
                                      // _buildLabel("Gender"),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        value: gender,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(
                                            0.85,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                        items: ["Male", "Female", "Other"]
                                            .map(
                                              (val) => DropdownMenuItem(
                                                value: val,
                                                child: Text(val),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) =>
                                            setState(() => gender = val!),
                                      ),

                                      const SizedBox(height: 28),
                                      _buildPrimaryButton(
                                        text: "Register",
                                        icon: Icons.arrow_forward,
                                        onPressed: _submit,
                                        loading: isLoading,
                                        color: themeColor,
                                      ),

                                      const SizedBox(height: 16),
                                      _buildGoogleButton(),

                                      const SizedBox(height: 16),
                                      Center(
                                        child: TextButton(
                                          onPressed: () =>
                                              Navigator.pushReplacementNamed(
                                                context,
                                                '/login',
                                              ),
                                          child: Text(
                                            "Already have an account? Log in",
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildLabel(String text) => Align(
  //   alignment: Alignment.centerLeft,
  //   child: Text(
  //     text,
  //     style: GoogleFonts.poppins(
  //       color: Colors.black87,
  //       fontSize: 15,
  //       fontWeight: FontWeight.w600,
  //     ),
  //   ),
  // );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade700),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.85),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required bool loading,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: Icon(icon, color: Colors.white),
        label: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    final themeColor = Colors.blueAccent;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        //  isLoading ? null : _handleGoogleSignIn,
        icon: Image.asset(
          'assets/images/7123025_logo_google_g_icon.png',
          width: 20,
          height: 20,
        ),
        label: Text(
          "Sign Up with Google",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: themeColor,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.25),
          side: BorderSide(color: themeColor),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

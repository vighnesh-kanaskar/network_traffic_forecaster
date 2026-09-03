import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:network_traffic_forecaster/pages/login_page.dart';
import '../services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool acceptedTerms = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  int get passwordScore {
    final password = passwordController.text;
    int score = 0;

    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

    return score;
  }

  String get passwordLabel {
    final password = passwordController.text;

    if (password.isEmpty) return 'Enter a password';

    switch (passwordScore) {
      case 1:
        return 'Too weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Too weak';
    }
  }

  bool get canCreateAccount {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    final emailValid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);

    return firstNameController.text.trim().isNotEmpty &&
        lastNameController.text.trim().isNotEmpty &&
        emailValid &&
        password.length >= 8 &&
        password == confirmPassword &&
        acceptedTerms;
  }

  Future<void> createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please accept the Terms of Service and Privacy Policy.',
          ),
        ),
      );
      return;
    }

    // Check your existing UI validation
    if (!canCreateAccount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all details correctly.')),
      );
      return;
    }

    try {
      // Create Firebase account
      await AuthService().signUp(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );

      // Go to Login Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'weak-password':
          message = 'Password is too weak.';
          break;

        case 'network-request-failed':
          message = 'Network error. Check your internet connection.';
          break;

        default:
          message = e.message ?? 'Unable to create account.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    }
  }

  void signIn() {
    Navigator.pop(context);
  }

  Widget buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
              color: Color(0xFF6A89A7),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            onChanged: (_) {
              setState(() {});
              onChanged?.call(controller.text);
            },
            style: const TextStyle(color: Color(0xFF384959), fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9BAFBE),
                fontSize: 13.5,
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: const Color(0xFF6A89A7).withOpacity(.30),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: const Color(0xFF6A89A7).withOpacity(.30),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF88BDF2),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE0685F)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFE0685F),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPasswordStrength() {
    final score = passwordScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (index) {
            Color color = const Color(0xFFCFD9E1);

            if (index < score) {
              if (score <= 2) {
                color = const Color(0xFFE0685F);
              } else if (score == 3) {
                color = const Color(0xFFF5A623);
              } else {
                color = const Color(0xFF4FAE8A);
              }
            }

            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 4,
                margin: EdgeInsets.only(right: index == 3 ? 0 : 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 5),
        Text(
          passwordLabel.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: .8,
            color: Color(0xFF6A89A7),
          ),
        ),
      ],
    );
  }

  Widget buildBrand() {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF384959), width: 2),
          ),
          child: Center(
            child: Container(
              width: 13,
              height: 13,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF88BDF2),
              ),
              child: Center(
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF384959),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF384959),
            ),
            children: [
              TextSpan(text: 'NETRA'),
              TextSpan(
                text: '.',
                style: TextStyle(color: Color(0xFF88BDF2)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildForecastPanel() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF384959), Color(0xFF2C3B47), Color(0xFF6A89A7)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: 100, left: 90, child: floatingNode()),
          Positioned(bottom: 160, right: 90, child: floatingNode()),
          Positioned(top: 260, right: 65, child: floatingNode()),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NETWORK TRAFFIC FORECASTER',
                      style: TextStyle(
                        color: Color(0xFFBDDDFC),
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Create your account and start forecasting risk in minutes.',
                      style: TextStyle(
                        color: Color(0xFFEAF2F8),
                        fontSize: 29,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'One dashboard for live traffic, anomaly alerts and threat-state forecasting.',
                      style: TextStyle(
                        color: Color(0xFFC3D4E0),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    buildChartCard(),
                    const SizedBox(height: 28),
                    buildPerks(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget floatingNode() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF88BDF2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF88BDF2).withOpacity(.5),
            blurRadius: 16,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RISK TREND — LAST 30 MIN',
            style: TextStyle(
              color: Color(0xFFBDDDFC),
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            width: double.infinity,
            child: CustomPaint(painter: RiskChartPainter()),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              buildStat('RISK', '41', true),
              const SizedBox(width: 12),
              buildStat('PACKETS/S', '1.2k', false),
              const SizedBox(width: 12),
              buildStat('FLOWS', '318', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildStat(String label, String value, bool risk) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(.14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9FB6C6),
                fontSize: 9,
                letterSpacing: .7,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: risk ? const Color(0xFFBDDDFC) : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPerks() {
    return const Column(
      children: [
        PerkItem(text: 'Real-time packet-level visibility'),
        SizedBox(height: 10),
        PerkItem(text: 'Forecasted threat states, not just alerts'),
        SizedBox(height: 10),
        PerkItem(text: 'History you can scrub back through'),
      ],
    );
  }

  Widget buildFormPanel() {
    return Container(
      color: const Color(0xFFF5FAFF),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildBrand(),
                    const SizedBox(height: 28),
                    const Text(
                      'Create your account',
                      style: TextStyle(
                        color: Color(0xFF384959),
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Set up access to the operations console.',
                      style: TextStyle(
                        color: Color(0xFF54697A),
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    buildSteps(),
                    const SizedBox(height: 2),

                    Row(
                      children: [
                        Expanded(
                          child: buildSocialButton(
                            icon: Icons.add_circle_outline,
                            text: 'Google',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: buildSocialButton(
                            icon: Icons.apps_rounded,
                            text: 'SSO',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: const Color(0xFF6A89A7).withOpacity(.30),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'OR SIGN UP WITH EMAIL',
                            style: TextStyle(
                              color: Color(0xFF6A89A7),
                              fontSize: 9.5,
                              letterSpacing: .8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: const Color(0xFF6A89A7).withOpacity(.30),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: buildTextField(
                            label: 'First name',
                            hint: 'Asha',
                            controller: firstNameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: buildTextField(
                            label: 'Last name',
                            hint: 'Rao',
                            controller: lastNameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    buildTextField(
                      label: 'Work email',
                      hint: 'you@network.io',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }

                        final valid = RegExp(
                          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                        ).hasMatch(value.trim());

                        if (!valid) {
                          return 'Enter a valid email address';
                        }

                        return null;
                      },
                    ),

                    buildTextField(
                      label: 'Password',
                      hint: 'Create a password',
                      controller: passwordController,
                      obscureText: obscurePassword,
                      suffixIcon: TextButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        child: Text(
                          obscurePassword ? 'SHOW' : 'HIDE',
                          style: const TextStyle(
                            color: Color(0xFF6A89A7),
                            fontSize: 10,
                            letterSpacing: .5,
                          ),
                        ),
                      ),
                    ),

                    buildPasswordStrength(),

                    const SizedBox(height: 15),

                    buildTextField(
                      label: 'Confirm password',
                      hint: 'Re-enter password',
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      suffixIcon: TextButton(
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                        child: Text(
                          obscureConfirmPassword ? 'SHOW' : 'HIDE',
                          style: const TextStyle(
                            color: Color(0xFF6A89A7),
                            fontSize: 10,
                            letterSpacing: .5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }

                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 3),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: acceptedTerms,
                            activeColor: const Color(0xFF88BDF2),
                            onChanged: (value) {
                              setState(() {
                                acceptedTerms = value ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                color: Color(0xFF6A89A7),
                                fontSize: 12,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: Color(0xFF384959),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Color(0xFF384959),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: canCreateAccount ? createAccount : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF384959),
                          disabledBackgroundColor: const Color(0xFFB7C1C9),
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shadowColor: const Color(0xFF384959).withOpacity(.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Create account',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: GestureDetector(
                        onTap: signIn,
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: Color(0xFF6A89A7),
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Sign in',
                                style: TextStyle(
                                  color: Color(0xFF384959),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
    );
  }

  Widget buildSteps() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF88BDF2), Color(0xFF384959)],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF6A89A7).withOpacity(.25),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSocialButton({required IconData icon, required String text}) {
    return SizedBox(
      height: 42,
      child: OutlinedButton.icon(
        onPressed: () {
          // Google/SSO authentication will be connected later.
        },
        icon: Icon(icon, size: 17, color: const Color(0xFF384959)),
        label: Text(
          text,
          style: const TextStyle(color: Color(0xFF384959), fontSize: 13),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: const Color(0xFF6A89A7).withOpacity(.30)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 860) {
            return Row(
              children: [
                Expanded(child: buildForecastPanel()),
                Expanded(child: buildFormPanel()),
              ],
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 520, child: buildForecastPanel()),
                buildFormPanel(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PerkItem extends StatelessWidget {
  final String text;

  const PerkItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF88BDF2).withOpacity(.18),
            border: Border.all(color: const Color(0xFF88BDF2).withOpacity(.5)),
          ),
          child: const Icon(Icons.check, size: 11, color: Color(0xFF88BDF2)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFFDBE8F1), fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class RiskChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      const Offset(0, .73),
      const Offset(.06, .67),
      const Offset(.12, .71),
      const Offset(.18, .55),
      const Offset(.24, .61),
      const Offset(.30, .45),
      const Offset(.36, .50),
      const Offset(.41, .36),
      const Offset(.47, .42),
      const Offset(.53, .27),
      const Offset(.59, .34),
      const Offset(.65, .22),
      const Offset(.71, .29),
      const Offset(.76, .16),
      const Offset(.82, .24),
      const Offset(.88, .12),
      const Offset(.94, .20),
      const Offset(1, .07),
    ];

    final path = Path();

    for (int i = 0; i < points.length; i++) {
      final point = Offset(
        points[i].dx * size.width,
        points[i].dy * size.height,
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    final linePaint = Paint()
      ..color = const Color(0xFFBDDDFC)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    final areaPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final areaPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x6688BDF2), Color(0x0088BDF2)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(areaPath, areaPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

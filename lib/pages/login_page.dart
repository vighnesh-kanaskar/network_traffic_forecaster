import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:network_traffic_forecaster/app_shell.dart';
import 'sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  double _rotateX = 0;
  double _rotateY = 0;

  late AnimationController _orbController;

  // NETRA colors from the HTML design
  static const Color skyLight = Color(0xFFBDDDFC);
  static const Color skyMid = Color(0xFF88BDF2);
  static const Color slate = Color(0xFF6A89A7);
  static const Color navy = Color(0xFF384959);

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  void _handlePointerMove(PointerEvent event, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    final x = (event.localPosition.dx / width) - 0.5;
    final y = (event.localPosition.dy / height) - 0.5;

    setState(() {
      _rotateY = x * 0.16;
      _rotateX = -y * 0.16;
    });
  }

  void _resetTilt() {
    setState(() {
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {});

    try {
      await AuthService().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Firebase login successful.
      // Open the complete NETRA application shell.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-credential':
          message = 'Invalid email or password.';
          break;

        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        case 'wrong-password':
          message = 'Incorrect password.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;

        default:
          message = e.message ?? 'Unable to sign in.';
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
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return MouseRegion(
            onHover: (event) {
              _handlePointerMove(event, constraints);
            },
            onExit: (_) => _resetTilt(),
            child: Stack(
              children: [
                // Background
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-0.4, -0.6),
                      radius: 1.4,
                      colors: [Color(0xFFF2F8FF), skyLight, skyMid],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

                // Decorative animated orbs
                _buildOrb(
                  size: 260,
                  left: constraints.maxWidth * 0.08,
                  top: constraints.maxHeight * 0.08,
                  color: navy.withOpacity(0.15),
                  animationOffset: 0,
                ),

                _buildOrb(
                  size: 200,
                  left: constraints.maxWidth * 0.78,
                  top: constraints.maxHeight * 0.70,
                  color: slate.withOpacity(0.30),
                  animationOffset: 0.25,
                ),

                _buildOrb(
                  size: 180,
                  left: constraints.maxWidth * 0.10,
                  top: constraints.maxHeight * 0.75,
                  color: Colors.white.withOpacity(0.60),
                  animationOffset: 0.50,
                ),

                // Main content
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 70,
                    ),
                    child: _buildCardStack(constraints),
                  ),
                ),

                // Template label
                Positioned(
                  top: 26,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'LOGIN NETRA FORECASTER',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        letterSpacing: 1.6,
                        color: navy.withOpacity(0.55),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrb({
    required double size,
    required double left,
    required double top,
    required Color color,
    required double animationOffset,
  }) {
    return AnimatedBuilder(
      animation: _orbController,
      builder: (context, child) {
        final animationValue = (_orbController.value + animationOffset) % 1.0;

        final movement = math.sin(animationValue * math.pi * 2) * 22;
        final scale = 1 + (math.sin(animationValue * math.pi * 2) * 0.025);

        return Positioned(
          left: left,
          top: top + movement,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(color: color, blurRadius: 50, spreadRadius: 15),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardStack(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 500;

    final cardWidth = isSmallScreen
        ? math.min(constraints.maxWidth - 40, 380.0)
        : 380.0;

    return SizedBox(
      width: cardWidth,
      height: 500,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_rotateX)
          ..rotateY(_rotateY),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Back card 2
            Positioned.fill(
              top: 34,
              child: Transform.rotate(
                angle: 5 * math.pi / 180,
                child: Transform.translate(
                  offset: const Offset(0, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [navy, slate],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: navy.withOpacity(0.20),
                          blurRadius: 35,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Back card 1
            Positioned.fill(
              top: 18,
              child: Transform.rotate(
                angle: -4 * math.pi / 180,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [skyMid, slate],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: slate.withOpacity(0.20),
                        blurRadius: 35,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main glass card
            Positioned.fill(child: _buildMainCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 38),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withOpacity(0.76),
          border: Border.all(color: Colors.white.withOpacity(0.85), width: 1),
          boxShadow: [
            BoxShadow(
              color: navy.withOpacity(0.28),
              blurRadius: 55,
              spreadRadius: -20,
              offset: const Offset(0, 35),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.70),
              blurRadius: 1,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Glass sheen
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.30),
                        Colors.transparent,
                        skyMid.withOpacity(0.08),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBrand(),

                  const SizedBox(height: 18),

                  const Text(
                    'Unlock your dashboard',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      color: navy,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Real-time traffic, risk & forecast — one login away.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF4D6373),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 26),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildEmailField(),

                        const SizedBox(height: 15),

                        _buildPasswordField(),

                        const SizedBox(height: 4),

                        _buildOptionsRow(),

                        const SizedBox(height: 20),

                        _buildSignInButton(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _buildCreateAccount(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: navy, width: 2),
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: skyMid,
              ),
              child: Center(
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: navy,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Text(
          'NETRA ACCESS',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            letterSpacing: 1.7,
            color: navy.withOpacity(0.70),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('EMAIL'),

        const SizedBox(height: 6),

        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 13.5, color: navy),
          decoration: _inputDecoration(hintText: 'you@network.io'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter your email';
            }

            if (!value.contains('@')) {
              return 'Enter a valid email';
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('PASSWORD'),

        const SizedBox(height: 6),

        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(fontSize: 13.5, color: navy),
          decoration: _inputDecoration(
            hintText: '••••••••',
            suffixIcon: TextButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: slate,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _obscurePassword ? 'SHOW' : 'HIDE',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter your password';
            }

            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: skyMid,
                checkColor: Colors.white,
                side: BorderSide(color: slate.withOpacity(0.55)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            const SizedBox(width: 5),

            const Text(
              'Remember me',
              style: TextStyle(fontSize: 12, color: slate),
            ),
          ],
        ),

        TextButton(
          onPressed: () {
            // Forgot password functionality will be added later.
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: slate,
          ),
          child: const Text('Forgot password?', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [skyMid, navy],
          ),
          boxShadow: [
            BoxShadow(
              color: navy.withOpacity(0.38),
              blurRadius: 26,
              spreadRadius: -10,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _signIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Sign in',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAccount() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12.5, color: slate),
          children: [
            const TextSpan(text: 'New to NETRA? '),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  );
                },
                child: const Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 10.5,
        letterSpacing: 0.8,
        color: slate,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: slate.withOpacity(0.55), fontSize: 13.5),
      filled: true,
      fillColor: Colors.white.withOpacity(0.75),

      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),

      suffixIcon: suffixIcon,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: slate.withOpacity(0.30), width: 1.5),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: slate.withOpacity(0.30), width: 1.5),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: skyMid, width: 1.5),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
import 'package:seamlesscall/features/auth/domain/appuser.dart';
import 'package:seamlesscall/features/auth/data/auth_repository.dart';
import 'package:seamlesscall/features/auth/presentation/otp_screen.dart';
import 'package:seamlesscall/app_shell/presentation/admin_shell.dart';
import 'package:seamlesscall/app_shell/presentation/provider_shell.dart';
import 'package:seamlesscall/app_shell/presentation/customer_shell.dart';
import 'package:seamlesscall/common/utils/phone_utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../common/constants/theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AuthRepository _authRepository;
  late AnimationController _entrance;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final identifier = normalizePhone(_phoneController.text.trim());
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter phone/email and password')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final user = await _authRepository.login(
        identifier: identifier,
        password: password,
      );

      Provider.of<AuthProvider>(context, listen: false).setUser(user);

      if (user.role == 'Admin' || user.role == 'Provider') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OtpScreen(phone: identifier)),
        );
      } else {
        _navigateDashboard(user);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _navigateDashboard(AppUser user) {
    switch (user.role) {
      case 'Admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminShell()),
        );
        break;
      case 'Provider':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProviderShell()),
        );
        break;
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomerShell()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 6),
            decoration: BoxDecoration(gradient: AppPalette.brandGradient),
          ),
          Positioned.fill(
            child: Container(
              color: theme.brightness == Brightness.light
                  ? Colors.black.withOpacity(0.03)
                  : Colors.black.withOpacity(0.25),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: Column(
                children: [
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _entrance,
                      curve: const Interval(0.0, 0.35),
                    ),
                    child: Image.asset(
                      'assets/images/logo4.png',
                      height: 200,
                      width: 200,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _entrance,
                      curve: const Interval(0.35, 0.7),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: theme.cardColor.withOpacity(
                                  theme.brightness == Brightness.light
                                      ? 0.9
                                      : 0.55,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Welcome back',
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      hintText: 'Phone number',
                                      prefixIcon: Icon(Icons.phone),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      hintText: 'Password',
                                      prefixIcon: Icon(Icons.lock),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        'Forgot password?',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: _submitting ? null : _login,
                                    child: _submitting
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Login'),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: theme.dividerColor
                                                .withOpacity(0.4),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            'or continue with',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.6),
                                                ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: theme.dividerColor
                                                .withOpacity(0.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        iconSize: 26,
                                        onPressed: () {
                                          // TODO: Google sign-in later
                                        },
                                        icon: const FaIcon(
                                          FontAwesomeIcons.google,
                                          color: Colors.red,
                                        ),
                                      ),

                                      const SizedBox(width: 20),

                                      IconButton(
                                        iconSize: 26,
                                        onPressed: () {
                                          // TODO: Facebook sign-in later
                                        },
                                        icon: const FaIcon(
                                          FontAwesomeIcons.facebook,
                                          color: Colors.blue,
                                        ),
                                      ),

                                      const SizedBox(width: 20),

                                      IconButton(
                                        iconSize: 26,
                                        onPressed: () {
                                          // TODO: Biometric / fingerprint later
                                        },
                                        icon: const FaIcon(
                                          FontAwesomeIcons.fingerprint,
                                          color: Color.fromARGB(
                                            221,
                                            148,
                                            216,
                                            248,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const RegisterScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Create an account',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.85),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _entrance,
                            curve: const Interval(0.8, 1.0),
                          ),
                          child: Text(
                            'SeamlessCall • Built for fast local services',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color.fromARGB(
                                255,
                                255,
                                255,
                                255,
                              ).withOpacity(0.85),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
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

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:seamlesscall/features/auth/domain/appuser.dart';
import 'package:seamlesscall/features/auth/data/auth_api.dart';
import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
import 'package:seamlesscall/features/auth/presentation/otp_screen.dart';
import 'package:seamlesscall/app_shell/presentation/admin_shell.dart';
import 'package:seamlesscall/app_shell/presentation/provider_shell.dart';
import 'package:seamlesscall/app_shell/presentation/customer_shell.dart';
import '../../../common/constants/theme.dart';
import '../../../common/widgets/gradient_button.dart';
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
  final _storage = const FlutterSecureStorage();
  late AnimationController _entrance;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final phoneOrEmail = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phoneOrEmail.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter phone/email and password')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final api = AuthApi();
      final data = await api.login(email: phoneOrEmail, password: password);

      // Parse user safely
      final userJson = data['user'] as Map<String, dynamic>;
      final user = AppUser.fromJson(userJson);
      final token = data['token'] as String;

      await _storage.write(key: 'auth_token', value: token);

      // Conditional OTP: only for Admins and Providers
      final role = data['user']['role'] ?? 'Customer';
      if (role == 'Admin' || role == 'Provider') {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OtpScreen(phone: phoneOrEmail, role: role, tempToken: token),
          ),
        );
      } else {
        // Direct login for customer
        _navigateDashboard(role);
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

  void _navigateDashboard(String role) {
    switch (role) {
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
                    child: Center(
                      child: ClipRRect(
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
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                      ),
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
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
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
                        color: theme.colorScheme.onPrimary.withOpacity(0.85),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

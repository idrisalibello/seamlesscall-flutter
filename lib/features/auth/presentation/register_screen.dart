import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/app_shell/presentation/customer_shell.dart';
import '../../../common/widgets/gradient_button.dart';
import 'login_screen.dart';
import 'package:seamlesscall/features/dashboard/dashboard_screen.dart';
import '../data/auth_repository.dart';
import '../data/auth_api.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  late AnimationController _entrance;

  final AuthRepository _authRepository = AuthRepository(
    api: AuthApi(),
  ); // provide your AuthApi instance
  bool _isLoading = false;

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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _passwordConfirmController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authRepository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation:
            password, // send same as password since backend expects it
        role: 'Customer', // hardcoded or use a selection
      );

      // Navigate to Dashboard
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const CustomerShell()),
      );
    } catch (e, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customer Registration failed: $e')),
      );
      // Print full error and stack trace to VSCode debug console
      print('=== Registration Error ===');
      print(e);
      print(stackTrace);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 5),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF001F4D),
                  Color(0xFF003C8F),
                  Color(0xFF0059FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: theme.brightness == Brightness.light
                  ? Colors.white.withOpacity(0.10)
                  : Colors.black.withOpacity(0.35),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
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
                  const SizedBox(height: 26),
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _entrance,
                      curve: const Interval(0.35, 1.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: theme.cardColor.withOpacity(
                              theme.brightness == Brightness.light
                                  ? 0.90
                                  : 0.50,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Account',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.person),
                                  hintText: 'Full Name',
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.email),
                                  hintText: 'Email Address',
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.phone),
                                  hintText: 'Phone Number',
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.lock),
                                  hintText: 'Password',
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _passwordConfirmController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline),
                                  hintText: 'Confirm Password',
                                ),
                              ),
                              const SizedBox(height: 18),
                              GradientButton(
                                label: _isLoading
                                    ? 'Registering...'
                                    : 'Register now',
                                onPressed: () {
                                  if (!_isLoading) _register();
                                },
                              ),

                              const SizedBox(height: 16),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Already have an account? Login',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.85),
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
                  const SizedBox(height: 26),
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _entrance,
                      curve: const Interval(0.8, 1.0),
                    ),
                    child: Text(
                      'SeamlessCall • Fast and Reliable Services',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.92),
                      ),
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

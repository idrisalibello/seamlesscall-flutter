import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

// import 'package:seamlesscall/features/auth/data/auth_api.dart'; // No longer needed directly
import 'package:seamlesscall/features/auth/data/auth_repository.dart'; // NEW: Import AuthRepository
import 'package:seamlesscall/app_shell/presentation/customer_shell.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Still needed for decoding token here
import 'package:seamlesscall/app_shell/presentation/admin_shell.dart';
import 'package:seamlesscall/app_shell/presentation/provider_shell.dart';
import 'package:seamlesscall/features/auth/domain/appuser.dart'; // For _navigateDashboard

class OtpScreen extends StatefulWidget {
  final String phone;

  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _verifying = false;
  // final _storage = const FlutterSecureStorage(); // No longer needed directly here
  late AuthRepository _authRepository; // Use AuthRepository

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository(); // Initialize AuthRepository
    _requestOtp(); // Request OTP when screen initializes
  }

  Future<void> _requestOtp() async {
    try {
      String formattedPhone = widget.phone;
      // Remove leading '0' if present and not already E.164
      if (formattedPhone.startsWith('0') && !formattedPhone.startsWith('+')) {
        formattedPhone =
            '234${formattedPhone.substring(1)}'; // Assuming Nigeria's country code is 234
      }
      // Ensure it starts with '+'
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+$formattedPhone';
      }

      await _authRepository.requestLoginOtp(formattedPhone);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP sent successfully')));
    } catch (e, stackTrace) {
      if (!mounted) return;
      print('Request OTP error: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to request OTP: ${e.toString()}')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) return;

    setState(() => _verifying = true);

    try {
      // Use AuthRepository for loginWithOtp
      final token = await _authRepository.loginWithOtp(
        widget.phone,
        _otpController.text.trim(),
      );

      // Decode JWT to get user role (AuthRepository handles token storage)
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final String role = decodedToken['role'] as String;

      // For navigation, create a minimal AppUser (since full data isn't returned by loginWithOtp)
      // This AppUser creation is a placeholder for navigation purposes.
      // A more robust solution would involve fetching the full user profile after token acquisition.
      final AppUser user = AppUser(
        id: decodedToken['id'],
        name: 'User', // Placeholder
        email: widget.phone.contains('@')
            ? widget.phone
            : 'placeholder@example.com', // Best guess
        phone: widget.phone.contains('@') ? 'N/A' : widget.phone, // Best guess
        role: role,
        status: 'active',
      );

      if (!mounted) return;
      _navigateDashboard(user); // Pass AppUser object for consistent navigation
    } on DioError catch (e, stackTrace) {
      print('DioError during OTP verification: $e');
      print('Stack trace: $stackTrace');
      final message = e.response?.data['message'] ?? 'OTP verification failed';
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e, stackTrace) {
      print('Generic error during OTP verification: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('OTP verification failed: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _verifying = false);
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
      default: // Customer or any other role
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomerShell()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('OTP sent to ${widget.phone}'),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(labelText: 'OTP'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _verifying ? null : _verifyOtp,
              child: _verifying
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String role;
  final String tempToken; // token from login API

  const OtpScreen({
    super.key,
    required this.phone,
    required this.role,
    required this.tempToken,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _verifying = false;
  final _storage = const FlutterSecureStorage();

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) return;

    setState(() => _verifying = true);

    try {
      final response = await Dio().post(
        'http://YOUR_API_URL/api/v1/otp/verify',
        data: {
          'phone': widget.phone,
          'otp': _otpController.text.trim(),
          'temp_token': widget.tempToken,
        },
      );

      final token = response.data['token'];
      await _storage.write(key: 'auth_token', value: token);

      if (!mounted) return;
      _navigateDashboard(widget.role);
    } on DioError catch (e) {
      final message = e.response?.data['message'] ?? 'OTP verification failed';
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  void _navigateDashboard(String role) {
    switch (role) {
      case 'Admin':
        Navigator.pushReplacementNamed(context, '/adminDashboard');
        break;
      case 'Provider':
        Navigator.pushReplacementNamed(context, '/providerDashboard');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/customerDashboard');
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

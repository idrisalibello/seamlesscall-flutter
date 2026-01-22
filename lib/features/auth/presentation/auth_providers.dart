import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:seamlesscall/features/auth/domain/appuser.dart';
import 'package:seamlesscall/features/auth/presentation/login_screen.dart';

class AuthProvider with ChangeNotifier {
  AppUser? _user;
  String? _otp;
  String? _name;
  String? _avatarUrl;
  final _storage = const FlutterSecureStorage();

  AppUser? get user => _user;

  bool hasPermission(String permission) {
    return _user?.permissions.contains(permission) ?? false;
  }

  void setUser(AppUser user) {
    _user = user;
    notifyListeners();
  }

  Future<void> logout(NavigatorState navigatorState) async {
    _user = null;
    await _storage.delete(key: 'auth_token');

    // Navigate to login screen and remove all other routes
    navigatorState.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );

    notifyListeners();
  }

  // Save phone/email
  void submitPhoneOrEmail(String value) {
    // Simulate sending OTP
    _otp = "123456"; // Always send 123456 as OTP
    notifyListeners();
  }

  // Verify OTP
  bool verifyOtp(String inputOtp) {
    return inputOtp == _otp;
  }

  // Save profile
  void saveProfile({required String name, String? avatarUrl}) {
    _name = name;
    _avatarUrl = avatarUrl;
    notifyListeners();
  }

  String? get name => _name;
  String? get avatarUrl => _avatarUrl;
}

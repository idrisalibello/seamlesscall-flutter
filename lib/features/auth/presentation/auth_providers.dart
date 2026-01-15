import 'package:flutter/material.dart';
import 'package:seamlesscall/features/auth/domain/appuser.dart';

class AuthProvider with ChangeNotifier {
  AppUser? _user;
  String? _otp;
  String? _name;
  String? _avatarUrl;

  AppUser? get user => _user;

  void setUser(AppUser user) {
    _user = user;
    notifyListeners();
  }

  void logout() {
    _user = null;
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

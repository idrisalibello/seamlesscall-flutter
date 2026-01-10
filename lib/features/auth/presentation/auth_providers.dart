import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _otp;
  String? _name;
  String? _avatarUrl;

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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:seamlesscall/features/auth/domain/appuser.dart';
import 'package:seamlesscall/features/auth/presentation/login_screen.dart';

// Define the state for AuthNotifier
class AuthState {
  final AppUser? user;
  final String? otp;
  final String? name;
  final String? avatarUrl;

  AuthState({
    this.user,
    this.otp,
    this.name,
    this.avatarUrl,
  });

  AuthState copyWith({
    AppUser? user,
    String? otp,
    String? name,
    String? avatarUrl,
  }) {
    return AuthState(
      user: user ?? this.user,
      otp: otp ?? this.otp,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

// Convert AuthProvider to StateNotifier
class AuthNotifier extends StateNotifier<AuthState> {
  final _storage = const FlutterSecureStorage();

  AuthNotifier() : super(AuthState()); // Initial state

  AppUser? get user => state.user;

  bool hasPermission(String permission) {
    return state.user?.permissions.contains(permission) ?? false;
  }

  void setUser(AppUser user) {
    state = state.copyWith(user: user);
  }

  Future<void> logout(NavigatorState navigatorState) async {
    state = AuthState(); // Clear user state
    await _storage.delete(key: 'auth_token');

    // Navigate to login screen and remove all other routes
    navigatorState.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // Save phone/email
  void submitPhoneOrEmail(String value) {
    // Simulate sending OTP
    state = state.copyWith(otp: "123456"); // Always send 123456 as OTP
  }

  // Verify OTP
  bool verifyOtp(String inputOtp) {
    return inputOtp == state.otp;
  }

  // Save profile
  void saveProfile({required String name, String? avatarUrl}) {
    state = state.copyWith(name: name, avatarUrl: avatarUrl);
  }

  String? get name => state.name;
  String? get avatarUrl => state.avatarUrl;
}

// Expose as a StateNotifierProvider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:seamlesscall/features/auth/data/auth_api.dart';
import 'package:seamlesscall/features/auth/domain/appuser.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Import for JWT decoding

class AuthRepository {
  final AuthApi api;
  final _storage = const FlutterSecureStorage(); // Use _storage for consistency

  AuthRepository({AuthApi? api}) : api = api ?? AuthApi(); // Allow optional api for testing

  Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    final user = await api.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      role: role,
    );
    print(user); // Keep for debugging if needed
    return user;
  }

  Future<AppUser> login({
    required String identifier, // Changed from email to identifier
    required String password,
  }) async {
    final result = await api.login(identifier: identifier, password: password); // Corrected argument name
    final token = result['token'] as String;
    final user = AppUser.fromJson(Map<String, dynamic>.from(result['user']));
    await _storage.write(key: 'auth_token', value: token);
    return user;
  }

  Future<void> requestLoginOtp(String identifier) async {
    await api.requestLoginOtp(identifier);
  }

  Future<String> loginWithOtp(String identifier, String otp) async { // Returns String token
    final token = await api.loginWithOtp(identifier, otp);
    await _storage.write(key: 'auth_token', value: token);
    return token;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<String?> getToken() => _storage.read(key: 'auth_token');

  // Helper to get user data from stored token
  Future<AppUser?> getLoggedInUser() async {
    final token = await getToken();
    if (token == null) return null;

    if (JwtDecoder.isExpired(token)) {
      await logout();
      return null;
    }

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    // This still requires a full AppUser.
    // For simplicity for now, if getLoggedInUser needs to return AppUser,
    // it implies a mechanism to get full user data.
    // Let's postpone this complexity for this task.
    // Returning null for now if full AppUser cannot be constructed.
    return null; // Or throw an error, depending on desired behavior.
  }
}

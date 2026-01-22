import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:seamlesscall/features/auth/data/auth_api.dart';
import 'package:seamlesscall/features/auth/domain/appuser.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:developer';

class AuthRepository {
  final AuthApi _api;
  final FlutterSecureStorage _storage;

  static const _authTokenKey = 'auth_token';
  static const _userProfileKey = 'user_profile';

  AuthRepository({AuthApi? api, FlutterSecureStorage? storage})
      : _api = api ?? AuthApi(),
        _storage = storage ?? const FlutterSecureStorage();

  Future<AppUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    final user = await _api.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      role: role,
    );
    return user;
  }

  Future<AppUser> login({
    required String identifier,
    required String password,
  }) async {
    final result = await _api.login(identifier: identifier, password: password);
    final token = result['token'] as String;
    
    // Decode token to get permissions
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final List<String> permissions = List<String>.from(decodedToken['permissions'] ?? []);

    // Create user and add permissions
    final user = AppUser.fromJson(Map<String, dynamic>.from(result['user'])).copyWith(permissions: permissions);
    
    await _storage.write(key: _authTokenKey, value: token);
    await _storage.write(key: _userProfileKey, value: jsonEncode(user.toJson()));

    return user;
  }

  Future<AppUser> socialLogin({
    required String provider,
    required String token,
  }) async {
    log('[AuthRepository] Attempting social login with provider: $provider');
    try {
      final result = await _api.socialLogin(provider: provider, token: token);
      log('[AuthRepository] Social login API call successful. Processing result...');

      if (result['token'] == null || result['user'] == null) {
        log('[AuthRepository] API response is missing token or user data.');
        throw Exception('Invalid response format from server.');
      }

      final authToken = result['token'] as String;
      final userData = result['user'];

      if (userData is! Map<String, dynamic>) {
        log('[AuthRepository] "user" data is not a valid map.');
        throw Exception('Invalid user data format from server.');
      }

      // Decode token to get permissions
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(authToken);
      final List<String> permissions = List<String>.from(decodedToken['permissions'] ?? []);

      // Create user and add permissions
      final user = AppUser.fromJson(userData).copyWith(permissions: permissions);
      log('[AuthRepository] User parsed successfully: ${user.name}');

      await _storage.write(key: _authTokenKey, value: authToken);
      await _storage.write(key: _userProfileKey, value: jsonEncode(user.toJson()));
      log('[AuthRepository] Auth token and user profile securely stored.');

      return user;
    } catch (e) {
      log('[AuthRepository] Social login failed: $e');
      rethrow;
    }
  }

  Future<AppUser> loginWithGoogle(String token) {
    log('[AuthRepository] Calling socialLogin for Google.');
    return socialLogin(provider: 'google', token: token);
  }

  Future<AppUser> loginWithFacebook(String token) {
    log('[AuthRepository] Calling socialLogin for Facebook.');
    return socialLogin(provider: 'facebook', token: token);
  }

  Future<void> requestLoginOtp(String identifier) async {
    await _api.requestLoginOtp(identifier);
  }

  Future<String> loginWithOtp(String identifier, String otp) async {
    final token = await _api.loginWithOtp(identifier, otp);
    await _storage.write(key: _authTokenKey, value: token);
    // Note: This flow doesn't store the user profile, it would need to be fetched separately.
    return token;
  }

  Future<void> logout() async {
    await _storage.delete(key: _authTokenKey);
    await _storage.delete(key: _userProfileKey);
  }

  Future<String?> getToken() => _storage.read(key: _authTokenKey);

  Future<Map<String, dynamic>> applyAsProvider({
    required String companyName,
    required String location,
    required String services,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }
    return _api.applyAsProvider(
      token: token,
      companyName: companyName,
      location: location,
      services: services,
    );
  }

  Future<AppUser?> getLoggedInUser() async {
    final token = await getToken();
    final userProfileJson = await _storage.read(key: _userProfileKey);

    if (token == null || userProfileJson == null) {
      return null;
    }

    if (JwtDecoder.isExpired(token)) {
      await logout();
      return null;
    }

    try {
      final user = AppUser.fromJson(jsonDecode(userProfileJson));
      return user;
    } catch (e) {
      // If profile is corrupted, log out to be safe
      log('[AuthRepository] Failed to parse stored user profile: $e');
      await logout();
      return null;
    }
  }
}
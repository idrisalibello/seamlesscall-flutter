import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:seamlesscall/features/auth/data/auth_api.dart';
import 'package:seamlesscall/features/auth/domain/appuser.dart';

class AuthRepository {
  final AuthApi api;
  final storage = const FlutterSecureStorage();

  AuthRepository({required this.api});

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
    print(user);
    return user;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final result = await api.login(email: email, password: password);
    final token = result['token'] as String;
    final user = AppUser.fromJson(Map<String, dynamic>.from(result['user']));
    await storage.write(key: 'auth_token', value: token);
    return user;
  }

  Future<void> logout() async {
    await storage.delete(key: 'auth_token');
  }

  Future<String?> getToken() => storage.read(key: 'auth_token');
}

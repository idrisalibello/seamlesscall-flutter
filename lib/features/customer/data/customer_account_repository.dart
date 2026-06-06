import 'package:seamlesscall/features/auth/domain/appuser.dart';
import 'package:seamlesscall/features/customer/data/customer_account_api.dart';

class CustomerAccountRepository {
  final CustomerAccountApi api;

  CustomerAccountRepository(this.api);

  Future<AppUser> profile() {
    return api.fetchProfile();
  }

  Future<AppUser> updateName(String name) {
    return api.updateName(name);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return api.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
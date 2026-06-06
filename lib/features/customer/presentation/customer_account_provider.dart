import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/auth/domain/appuser.dart';
import 'package:seamlesscall/features/customer/data/customer_account_api.dart';
import 'package:seamlesscall/features/customer/data/customer_account_repository.dart';

final customerAccountRepositoryProvider = Provider((ref) {
  return CustomerAccountRepository(
    CustomerAccountApi(),
  );
});

final customerProfileProvider = FutureProvider<AppUser>((ref) async {
  final repo = ref.watch(customerAccountRepositoryProvider);
  return repo.profile();
});